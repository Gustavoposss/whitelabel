import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';

class FiltersSidebar extends StatefulWidget {
  final VoidCallback onFiltersChanged;
  final VoidCallback? onClose;

  const FiltersSidebar({
    super.key,
    required this.onFiltersChanged,
    this.onClose,
  });

  @override
  State<FiltersSidebar> createState() => _FiltersSidebarState();
}

class _FiltersSidebarState extends State<FiltersSidebar> {
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedDepartments = {};
  double _minPrice = 0;
  double _maxPrice = 10000;
  String? _selectedProvider;
  bool _priceRangeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    
    // Initialize from existing filters
    _selectedProvider = productsProvider.providerFilter;
    
    // Initialize selected categories
    if (productsProvider.categoryFilter != null) {
      _selectedCategories.add(productsProvider.categoryFilter!);
    }
    
    // Initialize selected departments
    if (productsProvider.departmentFilter != null) {
      _selectedDepartments.add(productsProvider.departmentFilter!);
    }
    
    // Initialize price range from filters or products
    if (productsProvider.minPrice != null) {
      _minPrice = productsProvider.minPrice!;
      _minPriceController.text = _minPrice.toInt().toString();
    }
    if (productsProvider.maxPrice != null) {
      _maxPrice = productsProvider.maxPrice!;
      _maxPriceController.text = _maxPrice.toInt().toString();
    }
  }


  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final maxPriceLimit = productsProvider.maxProductPrice;
    final minPriceLimit = productsProvider.minProductPrice;
    
    final tolerance = (maxPriceLimit - minPriceLimit) * 0.01;
    final actualMinPrice = (_minPrice - minPriceLimit).abs() > tolerance ? _minPrice : null;
    final actualMaxPrice = (_maxPrice - maxPriceLimit).abs() > tolerance ? _maxPrice : null;
    
    productsProvider.setFilters(
      minPrice: actualMinPrice,
      maxPrice: actualMaxPrice,
      provider: _selectedProvider,
      category: _selectedCategories.isNotEmpty ? _selectedCategories.first : null,
      department: _selectedDepartments.isNotEmpty ? _selectedDepartments.first : null,
    );
    widget.onFiltersChanged();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedDepartments.clear();
      _selectedProvider = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      if (productsProvider.products.isNotEmpty) {
        _minPrice = productsProvider.minProductPrice;
        _maxPrice = productsProvider.maxProductPrice;
        _minPriceController.text = _minPrice.toInt().toString();
        _maxPriceController.text = _maxPrice.toInt().toString();
      } else {
        _minPrice = 0;
        _maxPrice = 10000;
      }
    });
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    productsProvider.clearFilters();
    widget.onFiltersChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, productsProvider, child) {
        final categories = productsProvider.categories;
        final departments = productsProvider.departments;
        final minProductPrice = productsProvider.minProductPrice;
        final maxProductPrice = productsProvider.maxProductPrice;
        
        if (productsProvider.maxProductPrice > 0 && !_priceRangeInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && productsProvider.minPrice == null && productsProvider.maxPrice == null) {
              setState(() {
                _minPrice = minProductPrice;
                _maxPrice = maxProductPrice;
                _minPriceController.text = _minPrice.toInt().toString();
                _maxPriceController.text = _maxPrice.toInt().toString();
                _priceRangeInitialized = true;
              });
            }
          });
        }
        
        final priceMax = maxProductPrice > 0 ? maxProductPrice : 10000.0;
        final priceMin = minProductPrice >= 0 ? minProductPrice : 0.0;
        
        final currentMinPrice = _minPrice.clamp(priceMin, priceMax);
        final currentMaxPrice = _maxPrice.clamp(priceMin, priceMax);
        if (currentMinPrice != _minPrice || currentMaxPrice != _maxPrice) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _minPrice = currentMinPrice;
                _maxPrice = currentMaxPrice;
                _minPriceController.text = _minPrice.toInt().toString();
                _maxPriceController.text = _maxPrice.toInt().toString();
              });
            }
          });
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (widget.onClose != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories
                    if (categories.isNotEmpty) ...[
                      _buildSection(
                        title: 'Categorias',
                        children: categories.map((category) {
                          return _buildCheckbox(
                            category,
                            category,
                            isCategory: true,
                            isSelected: _selectedCategories.contains(category),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Departments (only if different from categories)
                    if (departments.isNotEmpty && 
                        departments.any((d) => !categories.contains(d))) ...[
                      _buildSection(
                        title: 'Departamentos',
                        children: departments.map((department) {
                          return _buildCheckbox(
                            department,
                            department,
                            isDepartment: true,
                            isSelected: _selectedDepartments.contains(department),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Price Range
                    _buildSection(
                      title: 'Preço',
                      children: [
                        if (priceMax > priceMin)
                          RangeSlider(
                            values: RangeValues(
                              _minPrice.clamp(priceMin, priceMax),
                              _maxPrice.clamp(priceMin, priceMax),
                            ),
                            min: priceMin,
                            max: priceMax,
                            divisions: (priceMax - priceMin) > 100 
                                ? 100 
                                : ((priceMax - priceMin).round().clamp(1, 100)),
                            labels: RangeLabels(
                              'R\$ ${_minPrice.toInt()}',
                              'R\$ ${_maxPrice.toInt()}',
                            ),
                            onChanged: (values) {
                              setState(() {
                                _minPrice = values.start.roundToDouble();
                                _maxPrice = values.end.roundToDouble();
                                _minPriceController.text = _minPrice.toInt().toString();
                                _maxPriceController.text = _maxPrice.toInt().toString();
                              });
                              _applyFilters();
                            },
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('Carregando faixa de preços...'),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _minPriceController,
                                decoration: const InputDecoration(
                                  labelText: 'Mínimo',
                                  prefixText: 'R\$ ',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final price = double.tryParse(value);
                                  if (price != null && price >= priceMin && price <= priceMax) {
                                    setState(() {
                                      _minPrice = price;
                                    });
                                    _applyFilters();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _maxPriceController,
                                decoration: const InputDecoration(
                                  labelText: 'Máximo',
                                  prefixText: 'R\$ ',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final price = double.tryParse(value);
                                  if (price != null && price >= priceMin && price <= priceMax) {
                                    setState(() {
                                      _maxPrice = price;
                                    });
                                    _applyFilters();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Fornecedor',
                      children: [
                        _buildCheckbox(
                          'Brazilian',
                          'brazilian',
                          isProvider: true,
                          isSelected: _selectedProvider == 'brazilian',
                        ),
                        _buildCheckbox(
                          'European',
                          'european',
                          isProvider: true,
                          isSelected: _selectedProvider == 'european',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _clearFilters,
                        child: const Text('Limpar Filtros'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildCheckbox(
    String label,
    String value, {
    bool isCategory = false,
    bool isDepartment = false,
    bool isProvider = false,
    required bool isSelected,
  }) {
    return CheckboxListTile(
      title: Text(label),
      value: isSelected,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) {
        setState(() {
          if (isProvider) {
            _selectedProvider = checked! ? value : null;
          } else if (isCategory) {
            if (checked!) {
              _selectedCategories.add(value);
              _selectedDepartments.remove(value);
            } else {
              _selectedCategories.remove(value);
            }
          } else if (isDepartment) {
            if (checked!) {
              _selectedDepartments.add(value);
              _selectedCategories.remove(value);
            } else {
              _selectedDepartments.remove(value);
            }
          }
        });
        _applyFilters();
      },
    );
  }
}
