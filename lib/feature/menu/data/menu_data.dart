import 'package:flutter/material.dart';
import 'package:island_cafe/feature/menu/data/model/menu_category.dart';
import 'package:island_cafe/feature/menu/data/model/menu_item.dart';

class MenuData {
  static const List<MenuCategory> categories = [
    MenuCategory(
      id: 'best_sellers',
      name: 'BEST SELLERS',
      icon: Icons.star,
    ),
    MenuCategory(
      id: 'signature',
      name: 'SIGNATURE',
      icon: Icons.local_cafe,
    ),
    MenuCategory(
      id: 'iced_coffee',
      name: 'ICED COFFEE',
      icon: Icons.coffee,
    ),
    MenuCategory(
      id: 'hot_coffee',
      name: 'HOT COFFEE',
      icon: Icons.local_cafe,
    ),
    MenuCategory(
      id: 'milk_tea_juice',
      name: 'MILK, TEA & JUICE',
      icon: Icons.local_drink,
    ),
    MenuCategory(
      id: 'frappe',
      name: 'FRAPPE',
      icon: Icons.icecream,
    ),
    MenuCategory(
      id: 'rice',
      name: 'RICE',
      icon: Icons.restaurant,
    ),
    MenuCategory(
      id: 'noodles',
      name: 'NOODLES',
      icon: Icons.ramen_dining,
    ),
  ];

 
  static const List<MenuItem> menuItems = [
    MenuItem(
      id: '1',
      name: 'Grilled Chicken Wing Rice',
      description: 'Delicious grilled chicken wings served with white rice',
      price: 2.43,
      imageUrl: 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'best_sellers',
    ),
    MenuItem(
      id: '2',
      name: 'Bakthorm Rice',
      description: 'Traditional stir-fried dish with meat, vegetables, and boiled eggs',
      price: 3.4,
      imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'best_sellers',
    ),
    MenuItem(
      id: '3',
      name: 'Coconut Cream Latte',
      description: 'Rich coconut cream latte with a smooth finish',
      price: 2.43,
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'best_sellers',
    ),
    MenuItem(
      id: '4',
      name: 'Iced Thnol Coffee',
      description: 'Traditional iced coffee with a unique flavor',
      price: 2.43,
      imageUrl: 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'best_sellers',
    ),
    MenuItem(
      id: '5',
      name: 'Fresh Passion Juice',
      description: 'Refreshing passion fruit juice',
      price: 2.43,
      imageUrl: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'best_sellers',
    ),
    // Signature
    MenuItem(
      id: '6',
      name: 'Iced Thnol Coffee',
      description: 'Traditional iced coffee with a unique signature flavor',
      price: 2.43,
      imageUrl: 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'signature',
    ),
    // Iced Coffee
    MenuItem(
      id: '7',
      name: 'Iced Caramel Macchiato',
      description: 'Smooth espresso with caramel and steamed milk',
      price: 2.43,
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'iced_coffee',
    ),
    MenuItem(
      id: '8',
      name: 'Iced Americano',
      description: 'Classic iced Americano',
      price: 2.0,
      imageUrl: 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'iced_coffee',
    ),
    // Hot Coffee
    MenuItem(
      id: '9',
      name: 'Espresso',
      description: 'Strong and bold espresso',
      price: 1.8,
      imageUrl: 'https://images.unsplash.com/photo-1517487881594-2787fef5ebf7?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'hot_coffee',
    ),
    MenuItem(
      id: '10',
      name: 'Cappuccino',
      description: 'Espresso with steamed milk foam',
      price: 2.2,
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'hot_coffee',
    ),
    // Milk, Tea & Juice
    MenuItem(
      id: '11',
      name: 'Green Tea',
      description: 'Refreshing green tea',
      price: 1.5,
      imageUrl: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'milk_tea_juice',
    ),
    MenuItem(
      id: '12',
      name: 'Mango Juice',
      description: 'Fresh mango juice',
      price: 2.0,
      imageUrl: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'milk_tea_juice',
    ),
    // Frappe
    MenuItem(
      id: '13',
      name: 'Chocolate Frappe',
      description: 'Rich chocolate frappe',
      price: 2.5,
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'frappe',
    ),
    MenuItem(
      id: '14',
      name: 'Vanilla Frappe',
      description: 'Smooth vanilla frappe',
      price: 2.5,
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'frappe',
    ),
    // Rice
    MenuItem(
      id: '15',
      name: 'Fried Rice',
      description: 'Classic fried rice with vegetables',
      price: 3.0,
      imageUrl: 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'rice',
    ),
    MenuItem(
      id: '16',
      name: 'Beef Rice Bowl',
      description: 'Tender beef served over rice',
      price: 3.5,
      imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'rice',
    ),
    // Noodles
    MenuItem(
      id: '17',
      name: 'Beef Noodles',
      description: 'Traditional beef noodles',
      price: 3.2,
      imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'noodles',
    ),
    MenuItem(
      id: '18',
      name: 'Chicken Noodles',
      description: 'Delicious chicken noodles',
      price: 3.0,
      imageUrl: 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=400&h=400&q=80',
      categoryId: 'noodles',
    ),
  ];

  static List<MenuItem> getItemsByCategory(String categoryId) {
    return menuItems.where((item) => item.categoryId == categoryId).toList();
  }
}

