<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use App\Http\Requests\Products\ProductRequest;
use App\Http\Resources\ProductResource;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $perPage = (int)($request->query('per_page', 20));
        $perPage = max(1, min(100, $perPage));

        $products = Product::query()
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate($perPage);

        return ProductResource::collection($products);
    }

    public function store(ProductRequest $request)
    {
        $product = Product::create([
            'user_id'        => $request->user()->id,
            'title'          => $request->title,
            'sku'            => $request->sku,
            'description'    => $request->description,
            'main_image'     => $request->main_image,
            'cost_price'     => $request->cost_price,
            'desired_margin' => $request->desired_margin,
            'attributes'     => $request->attributes,
        ]);

        return (new ProductResource($product))->response()->setStatusCode(201);
    }

    public function show(Request $request, $id)
    {
        $product = Product::where('user_id', $request->user()->id)->findOrFail($id);
        return new ProductResource($product);
    }

    public function update(ProductRequest $request, $id)
    {
        $product = Product::where('user_id', $request->user()->id)->findOrFail($id);

        $product->update($request->validated());

        return new ProductResource($product);
    }

    public function destroy(Request $request, $id)
    {
        Product::where('user_id', $request->user()->id)->findOrFail($id)->delete();

        return response()->json(['message' => 'Product deleted']);
    }
}
