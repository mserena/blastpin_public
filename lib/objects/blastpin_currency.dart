class BlastPinCurrency {
  String code;
  String name;
  String symbol;

  BlastPinCurrency(
    {
    required this.code, 
    required this.name, 
    required this.symbol,
    }
  );

  @override
  String toString(){
    return 'Currency $code: $name ($symbol)';
  }
}