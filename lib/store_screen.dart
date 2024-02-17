import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final List<Map> _prods = [];
  final List<int> _cartItems = [];
  final List<Map> _cartItemsMap = [];
  List<Map> _searchItems = [];

  int _page = 0;

  @override
  void initState() {
    super.initState();
    Uri uri = Uri.parse("https://fakestoreapi.com/products");
    get(uri).then((res) {
      final data = jsonDecode(res.body) as List;
      setState(() {
        _prods.addAll(data.map((e) => e as Map));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: appBar(),
      bottomNavigationBar: navigationBar(),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          if(_page != 2) searchBar(),
          const SizedBox(
            height: 15,
          ),
          if (_prods.isEmpty) ...[
            const Spacer(),
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.green.shade300,
              ),
            ),
            const Spacer()
          ] else
            _page == 0
                ? carouselSlider()
                : _page == 1
                    ? listWidget()
                    : chechoutWidget(),
        ],
      ),
    );
  }

  listWidget() {
    var items = _prods;
    if (_searchItems.isNotEmpty) {
      items = _searchItems;
    }
    return Expanded(
      child: ListView(
        children: items.map((e) {
          return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              margin: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    e['image'],
                    height: 100,
                    width: 60,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(e['title']),
                        const SizedBox(
                          height: 5,
                        ),
                        addCartBtn(e),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  productRating(e),
                ],
              ));
        }).toList(),
      ),
    );
  }

  chechoutWidget() {
    var items = _cartItemsMap;
    if (_searchItems.isNotEmpty) {
      items = _searchItems;
    }

    double totalPrice = _cartItemsMap.fold(
        0, (previousValue, element) => previousValue + element['price']);

    totalPrice = totalPrice.roundToDouble();

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: items.map((e) {
                return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    margin: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          e['image'],
                          height: 100,
                          width: 60,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(e['title']),
                              const SizedBox(
                                height: 5,
                              ),
                              addCartBtn(e),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        productRating(e),
                      ],
                    ));
              }).toList(),
            ),
          ),
          Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Item Count: ${_cartItemsMap.length}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "Total Price: \$${totalPrice}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Container searchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 25,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Colors.grey,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              onChanged: (v) {
                setState(() {
                  _searchItems = _prods
                      .where((prod) => (prod['title'] as String)
                          .toLowerCase()
                          .contains(v.toLowerCase()))
                      .toList();
                });
              },
              decoration: const InputDecoration(
                hintText: "Search for products",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar navigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey.shade400,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: _page,
      onTap: (v) {
        setState(() {
          _page = v;
        });
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.swipe), label: "Swipe"),
        const BottomNavigationBarItem(icon: Icon(Icons.list), label: "List"),
        const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout), label: "Checkout"),
      ],
    );
  }

  CarouselSlider carouselSlider() {
    var items = _prods;
    if (_searchItems.isNotEmpty) {
      items = _searchItems;
    }
    return CarouselSlider(
        items: items.map((e) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 20.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: productRating(e),
                      ),
                      const Spacer(),
                      Image.network(
                        e['image'],
                        height: 200,
                      ),
                      const Spacer(),
                      Text(
                        e["title"],
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        e["description"],
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      addCartBtn(e),
                    ],
                  ),
                )),
          );
        }).toList(),
        options: CarouselOptions(
          height: 480,
          enlargeCenterPage: true,
          enlargeFactor: 0.2,
          autoPlay: true,
          autoPlayAnimationDuration: const Duration(seconds: 2),
        ));
  }

  Container productRating(Map<dynamic, dynamic> e) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.blueGrey.shade50,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Colors.amber,
            size: 15,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            "${e['rating']['rate']} / 5",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Row addCartBtn(Map<dynamic, dynamic> e) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "\$${e['price']}",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        InkWell(
          onTap: () {
            setState(() {
              int id = e['id'];
              if (_cartItems.contains(id)) {
                _cartItems.remove(id);
                _cartItemsMap.remove(e);
              } else {
                _cartItemsMap.add(e);
                _cartItems.add(id);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.shade50,
            ),
            child: Icon(
              _cartItems.contains(e['id'])
                  ? Icons.remove_shopping_cart
                  : Icons.shopping_cart_rounded,
              size: 20,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.green.shade50,
      elevation: 0,
      iconTheme: const IconThemeData(color: const Color(0xff9BCF53)),
      title: const Center(
        child: Text(
          "ShopEazy",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xff9BCF53),
          ),
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_rounded)),
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(5),
                child: Text(
                  "${_cartItems.length}",
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff9BCF53)),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
