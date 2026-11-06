/// Describes one icon slot in `AppBottomNavBar`.
final class NavBarItem {
  const NavBarItem({
    required this.iconAsset,
    required this.semanticLabel,
    this.activeIconAsset,
  });

  /// The resting icon. It is tinted brand red when selected unless
  /// [activeIconAsset] is provided.
  final String iconAsset;

  /// A dedicated asset for the selected state, when the design has one.
  final String? activeIconAsset;

  final String semanticLabel;
}
