/// The fixed top-level browse tabs shown on the home screen, SHEIN-style.
///
/// "New In" and "Women" both browse the full catalog (there's no gender
/// split or separate "new arrivals" feed yet) — "Shoes" and "Accessories"
/// filter to their matching backend category by name, and "Sale" filters
/// client-side to products currently on sale.
enum HomeTab {
  newIn('New In'),
  women('Women'),
  shoes('Shoes'),
  accessories('Accessories'),
  sale('Sale');

  final String label;

  const HomeTab(this.label);
}
