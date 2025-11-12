import { Injectable, NotFoundException } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { Product, ProviderResponse } from './interfaces/product.interface';
import { ProductFilterDto } from './dto/product-filter.dto';

const BRAZILIAN_PROVIDER_URL = 'http://616d6bdb6dacbb001794ca17.mockapi.io/devnology/brazilian_provider';
const EUROPEAN_PROVIDER_URL = 'http://616d6bdb6dacbb001794ca17.mockapi.io/devnology/european_provider';

@Injectable()
export class ProductsService {
  constructor(private readonly httpService: HttpService) {}

  private normalizeToArray(data: any): any[] {
    if (Array.isArray(data)) {
      return data;
    }
    
    if (typeof data === 'object' && data !== null) {
      const keys = Object.keys(data);
      const numericKeys = keys.filter(key => !isNaN(Number(key)));
      
      if (numericKeys.length > 0) {
        return numericKeys
          .sort((a, b) => Number(a) - Number(b))
          .map(key => data[key])
          .filter(item => item && typeof item === 'object');
      }
      
      if (data.id || data.nome || data.name) {
        return [data];
      }
      
      for (const key of keys) {
        if (Array.isArray(data[key])) {
          return data[key];
        }
      }
      
      return [];
    }
    
    return [];
  }

  private async fetchFromBrazilianProvider(): Promise<ProviderResponse[]> {
    try {
      const response = await firstValueFrom(
        this.httpService.get<any>(BRAZILIAN_PROVIDER_URL),
      );
      return this.normalizeToArray(response.data);
    } catch (error) {
      return [];
    }
  }

  private async fetchFromEuropeanProvider(): Promise<ProviderResponse[]> {
    try {
      const response = await firstValueFrom(
        this.httpService.get<any>(EUROPEAN_PROVIDER_URL),
      );
      return this.normalizeToArray(response.data);
    } catch (error) {
      return [];
    }
  }

  private async fetchProductByIdFromProvider(
    id: string,
    provider: 'brazilian' | 'european',
  ): Promise<ProviderResponse | null> {
    try {
      const url =
        provider === 'brazilian'
          ? `${BRAZILIAN_PROVIDER_URL}/${id}`
          : `${EUROPEAN_PROVIDER_URL}/${id}`;
      const response = await firstValueFrom(this.httpService.get<ProviderResponse>(url));
      return response.data;
    } catch (error) {
      return null;
    }
  }

  private transformToProduct(
    item: any,
    provider: 'brazilian' | 'european',
  ): Product | null {
    if (!item || typeof item !== 'object' || Array.isArray(item)) {
      return null;
    }

    let name: string | undefined;
    let description: string | undefined;
    let preco: any;
    let categoria: string | undefined;
    let imagem: string | undefined;

    if (provider === 'brazilian') {
      name = item.nome || item.name;
      description = item.descricao || item.description;
      preco = item.preco || item.price;
      categoria = item.categoria || item.category;
      imagem = item.imagem || item.image;
    } else {
      name = item.name || item.nome;
      description = item.description || item.descricao;
      preco = item.price || item.preco;
      categoria = item.category || item.categoria;
      imagem = item.image || item.imagem;
    }

    if (!name || !item.id) {
      return null;
    }

    let priceValue = 0;
    if (typeof preco === 'number') {
      priceValue = preco;
    } else if (typeof preco === 'string') {
      const cleanedPrice = preco.replace(/[^\d.,]/g, '').replace(',', '.');
      priceValue = parseFloat(cleanedPrice) || 0;
    }

    if (priceValue === 0 && !preco) {
      return null;
    }

    let imageUrl: string | undefined = undefined;
    if (imagem && typeof imagem === 'string' && (imagem.startsWith('http') || imagem.startsWith('https'))) {
      imageUrl = imagem;
    } else if (item.image && typeof item.image === 'string' && (item.image.startsWith('http') || item.image.startsWith('https'))) {
      imageUrl = item.image;
    } else if (item.gallery && Array.isArray(item.gallery) && item.gallery.length > 0) {
      const firstImage = item.gallery.find((img: string) => 
        img && typeof img === 'string' && (img.startsWith('http') || img.startsWith('https'))
      );
      if (firstImage) {
        imageUrl = firstImage;
      }
    }

    const category = categoria || item.category || item.details?.material || item.material || undefined;
    const id = String(item.id);

    const product: Product = {
      id,
      name: String(name),
      description: description ? String(description) : undefined,
      price: priceValue,
      category: category ? String(category) : undefined,
      image: imageUrl,
      provider,
    };

    if (item.hasDiscount !== undefined) {
      product.hasDiscount = Boolean(item.hasDiscount);
    }
    if (item.discountValue) {
      product.discountValue = String(item.discountValue);
    }
    if (item.details && typeof item.details === 'object') {
      product.details = item.details;
    }
    if (item.gallery && Array.isArray(item.gallery)) {
      product.gallery = item.gallery;
    }
    
    if (item.departamento) {
      product.departamento = String(item.departamento);
    }
    if (item.material || item.details?.material) {
      product.material = String(item.material || item.details.material);
    }

    return product;
  }

  private filterProducts(products: Product[], filter: ProductFilterDto): Product[] {
    let filtered = [...products];

    if (filter.provider) {
      filtered = filtered.filter((p) => p.provider === filter.provider);
    }

    if (filter.name) {
      const nameLower = filter.name.toLowerCase();
      filtered = filtered.filter((p) =>
        p.name.toLowerCase().includes(nameLower),
      );
    }

    if (filter.category) {
      filtered = filtered.filter((p) => p.category === filter.category);
    }

    if (filter.minPrice !== undefined) {
      filtered = filtered.filter((p) => p.price >= filter.minPrice!);
    }

    if (filter.maxPrice !== undefined) {
      filtered = filtered.filter((p) => p.price <= filter.maxPrice!);
    }

    return filtered;
  }

  async findAll(filter?: ProductFilterDto): Promise<Product[]> {
    const providers: ('brazilian' | 'european')[] = filter?.provider
      ? [filter.provider as 'brazilian' | 'european']
      : ['brazilian', 'european'];

    const promises = providers.map((provider) => {
      return provider === 'brazilian'
        ? this.fetchFromBrazilianProvider()
        : this.fetchFromEuropeanProvider();
    });

    const results = await Promise.all(promises);
    let allProducts: Product[] = [];

    results.forEach((products, index) => {
      const provider = providers[index];
      const transformed = products
        .map((item) => this.transformToProduct(item, provider))
        .filter((product) => product !== null && product !== undefined);
      allProducts = [...allProducts, ...transformed];
    });

    if (filter) {
      allProducts = this.filterProducts(allProducts, filter);
    }

    return allProducts;
  }

  async findOne(id: string, provider?: 'brazilian' | 'european'): Promise<Product> {
    if (provider) {
      const product = await this.fetchProductByIdFromProvider(id, provider);
      if (!product) {
        throw new NotFoundException(`Product with ID ${id} not found in ${provider} provider`);
      }
      const transformed = this.transformToProduct(product, provider);
      if (!transformed) {
        throw new NotFoundException(`Product with ID ${id} not found in ${provider} provider`);
      }
      return transformed;
    }

    const [brazilianProduct, europeanProduct] = await Promise.all([
      this.fetchProductByIdFromProvider(id, 'brazilian'),
      this.fetchProductByIdFromProvider(id, 'european'),
    ]);

    if (brazilianProduct) {
      const transformed = this.transformToProduct(brazilianProduct, 'brazilian');
      if (transformed) {
        return transformed;
      }
    }

    if (europeanProduct) {
      const transformed = this.transformToProduct(europeanProduct, 'european');
      if (transformed) {
        return transformed;
      }
    }

    throw new NotFoundException(`Product with ID ${id} not found`);
  }
}

