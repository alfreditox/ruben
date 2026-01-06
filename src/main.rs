use std::fs;
use std::io;
use std::path::Path;
use std::process::Command;

// Embed the zip file into the executable.
// The user MUST place 'release.zip' in the 'src' directory before building.
const PAYLOAD: &[u8] = include_bytes!("release.zip");

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 1. Determine the path to the 'data' directory next to the executable
    let exe_path = std::env::current_exe()?;
    let exe_dir = exe_path.parent().unwrap_or(Path::new("."));
    let data_dir = exe_dir.join("data");

    // 2. Check if 'data' exists. If not, extract the payload.
    if !data_dir.exists() {
        println!("Primera ejecución detectada. Extrayendo archivos...");
        println!("Esto puede tardar un momento.");
        extract_zip(PAYLOAD, &data_dir)?;
    } else {
        println!("Directorio 'data' encontrado. Iniciando...");
    }

    // 3. Construct the paths to Python and FlatCAM
    // IMPORTANTE: Esto asume que dentro del zip hay una estructura como:
    // data/
    //   |-- python/
    //   |     |-- python.exe
    //   |-- FlatCAM/
    //         |-- FlatCAM.py
    //
    // O si el zip tiene el contenido plano, ajusta las rutas abajo.
    // Asumiremos que el zip extrae carpetas "python" y "FlatCAM" directamente en "data".

    let python_exe = data_dir.join("python").join("python.exe");
    let flatcam_script = data_dir.join("FlatCAM").join("FlatCAM.py");

    if !python_exe.exists() {
        eprintln!("Error: No se encuentra Python en {:?}", python_exe);
        eprintln!("Verifica la estructura de tu release.zip");
        return Ok(());
    }

    if !flatcam_script.exists() {
        eprintln!("Error: No se encuentra FlatCAM en {:?}", flatcam_script);
        eprintln!("Verifica la estructura de tu release.zip");
        return Ok(());
    }

    // 4. Launch FlatCAM
    // Run inside the FlatCAM directory so relative assets work and sys.path is correct
    let flatcam_dir = flatcam_script.parent().unwrap();

    let mut child = Command::new(python_exe)
        .arg(&flatcam_script)
        .current_dir(flatcam_dir)
        .spawn()?;

    // Wait for the process to finish
    let status = child.wait()?;

    println!("FlatCAM cerrado con código: {}", status);

    Ok(())
}

fn extract_zip(data: &[u8], target_dir: &Path) -> Result<(), Box<dyn std::error::Error>> {
    let reader = std::io::Cursor::new(data);
    let mut zip = zip::ZipArchive::new(reader)?;

    for i in 0..zip.len() {
        let mut file = zip.by_index(i)?;
        let outpath = match file.enclosed_name() {
            Some(path) => target_dir.join(path),
            None => continue,
        };

        let is_dir = file.name().ends_with('/') || file.name().ends_with('\\');

        if is_dir {
            // println!("Dir: {:?}", file.name());
            if let Err(e) = fs::create_dir_all(&outpath) {
                eprintln!("Failed to create dir {:?}: {}", file.name(), e);
                return Err(Box::new(e));
            }
        } else {
            // println!("Extracting: {:?}", file.name());
            if let Some(p) = outpath.parent() {
                if !p.exists() {
                    if let Err(e) = fs::create_dir_all(p) {
                        eprintln!("Failed to create parent dir {:?}: {}", p, e);
                        return Err(Box::new(e));
                    }
                }
            }
            let mut outfile = fs::File::create(&outpath).map_err(|e| {
                eprintln!("Failed to create file {:?}: {}", file.name(), e);
                e
            })?;
            io::copy(&mut file, &mut outfile)?;
        }

        // Get and Set permissions for Unix (optional, but good practice)
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            if let Some(mode) = file.unix_mode() {
                fs::set_permissions(&outpath, fs::Permissions::from_mode(mode))?;
            }
        }
    }

    Ok(())
}
