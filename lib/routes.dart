/// Route names (UI numbers from the SRS in comments).
class Routes {
  static const welcome = '/'; // Welcome
  static const setupAccount = '/setup/account'; // UI-01 step 1
  static const setupProfile = '/setup/profile'; // UI-01 step 2
  static const setupDone = '/setup/done'; // UI-01 step 3
  static const login = '/login'; // UI-02
  static const home = '/home'; // UI-03 + bottom tabs
  static const sell = '/sell'; // Booth sale
  static const addDesign = '/stock/add-design';
  static const bestSellers = '/best-sellers';
  static const sales = '/sales'; // UI-07
  static const saleDetail = '/sales/detail'; // UI-08, argument: sale id
  static const newOrder = '/orders/new';
  static const orderDetail = '/orders/detail'; // argument: order id
  static const addEvent = '/calendar/add';
  static const settings = '/settings';
}
