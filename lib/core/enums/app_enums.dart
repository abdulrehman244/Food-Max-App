enum UserStatus {
  loggedIn,
  loggedOut,
  unknown,
}

enum LoadingState {
  idle,
  loading,
  success,
  error,
}

enum PaymentMethod {
  cashOnDelivery,
  creditCard,
  debitCard,
  jazzCash,
  easyPaisa,
}

enum OrderStatus {
  pending,
  preparing,
  onTheWay,
  delivered,
  cancelled,
}
