fn main() {
    println!("Hello from 32-bit Rust!");
    println!("Presiona Enter para salir...");
    let mut input = String::new();
    std::io::stdin().read_line(&mut input).unwrap();
}
