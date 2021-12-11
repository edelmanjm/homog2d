Polyline is templated by type
`enum class PType uint8_t { Closed, Open };`
```
template<typename T>
class PolylineBase
{

};


template<typename FPT>
using OPolyline_<FPT> = PolylineBase<detail::PType::Open,FPT>;

template<typename FPT>
using CPolyline_<FPT> = PolylineBase<detail::PType::Open,FPT>;
```

## Difference between these two types:

Both types can be seen as a container of a set of points.
Order of points will be retained, but some normalizing step will occur, that will be different for the two types.

- The CPolyline_ type will get normalized (rotated) so that the smallest point is placed in first position,
and reversed so that the **second** smallest point is placed in second position.

- The OPolyline_ type will get reversed so that the smallest point is placed in first position

For both types, the normalisation occurs only when needed (first comparison).

The rationale for that normalization is that we want to be able to detect identical objects.
For example, the single-segment Polyline object described by the points `(0,0)-(1,1)`
is obviously the same as the one describeb by `(1,1)-(0,0)`

### Conversions:

Say we have:
```
OPolyline_ po;
CPolyline_ pc;
```

This is possible: `pc = po;`

(the first point gets connected to the last one)

This is **not** possible: `po = pc;`

because we would be unable to determine which segment needs to be removed.

### Initializing

The default constructor will build an empty object (which is perfectly valid).

Since there is a normalizing step involved, it is not possible for both types to add points "on the fly".
You will need to first build a vector of points, then assigning it to the Polyline object:
```
std::vector<Point2d> vec{ {0,0},{1,0},{1,1} };
OPolyline po(vec);
CPolyline pc(vec);
```
(`std::vector` is an example but you can use `std::array` or `std::list`)

However, it is possible to replace all the points of a Polyline by another set of points:
```
OPolyline po(vec1);
CPolyline pc(vec1);
po.set( vec2 );
pc.set( vec2 );
```

The minimum size is 2 points, a Polyline of 1 point is not legal.
Thus, this will throw:
```
std::vector<Point2d> vec{ {0,0} };
OPolyline po(vec);
CPolyline pc(vec);
```

Another constructor enables building a Polyline from a Segment, wich ends up with a Polyline of 2 points:
```
Segment seg; // default constructor
OPolyline po(seg);
CPolyline pc(seg);

```












