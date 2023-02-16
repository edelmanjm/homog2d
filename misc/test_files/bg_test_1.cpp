/**
\file
\brief  test of importing a polygon from Boost Geometry

\note 20230216: preliminar feature, will be expanded )

run with `$ make test_bgtest`
*/

#define HOMOG2D_USE_BOOSTGEOM
#include "../../homog2d.hpp"

int main()
{
	namespace bg = boost::geometry;

// build a boost geometry polygon
	using point_t1 = bg::model::point<double, 2, bg::cs::cartesian>;
	using cpolygon_t1 = bg::model::polygon<point_t1,true,true>;
	using opolygon_t1 = bg::model::polygon<point_t1,true,false>;

	cpolygon_t1 cpoly1{{ {0.0, 0.0}, {0.0, 5.0}, {5.0, 5.0}, {5.0, 0.0}, {0.0, 0.0} }};
	opolygon_t1 opoly1{{ {0.0, 0.0}, {0.0, 5.0}, {5.0, 5.0}, {5.0, 0.0} }};

	h2d::CPolyline p1a( cpoly1 );
	h2d::OPolyline p1b( opoly1 );
	std::cout << "p1a=" << p1a << "p1b=" << p1b << '\n';


	using point_t2 = bg::model::d2::point_xy<double>;
	using cpolygon_t2 = bg::model::polygon<point_t2,true,true>;
	using opolygon_t2 = bg::model::polygon<point_t2,true,false>;

	cpolygon_t2 cpoly2{{ {0.0, 0.0}, {0.0, 5.0}, {5.0, 5.0}, {5.0, 0.0}, {0.0, 0.0} }};
	opolygon_t2 opoly2{{ {0.0, 0.0}, {0.0, 5.0}, {5.0, 5.0}, {5.0, 0.0} }};

	h2d::CPolyline p2a( cpoly2 );
	h2d::OPolyline p2b( opoly2 );
	std::cout << "p2a=" << p2a << "p2b=" << p2b << '\n';

}