enum SpaceMode {
  /// Keep spaces in place; only alphabet symbols are transformed.
  keep,

  /// Split by spaces, transform each word, join back with spaces.
  perWord,
}

enum SpaceSupport {
  /// Spaces are kept in place (typical for substitution).
  keep,

  /// User may choose keep (whole text) or per-word processing.
  choosable,

  /// Spaces are not accepted in input.
  none,
}
