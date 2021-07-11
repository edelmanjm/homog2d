/**
\file showcase1.cpp
\brief Generates showcase images
*/
#define HOMOG2D_USE_OPENCV
#include "../homog2d.hpp"

#include "opencv2/highgui.hpp"

using namespace homog2d;

int main( int argc, const char** argv )
{
	int n=20;
	cv::Mat img;
	auto im_w = 400;
	auto im_h = 250;
	img.create( im_h, im_w, CV_8UC3 );

	int offset_h = 100;
	int offset_v = 60;
	Homogr Hr( M_PI/n );
	Homogr HT1(  im_w/2,  100 );
	Homogr HT2( -im_w/2, -100 );
	Homogr H = HT1 * Hr * HT2;

	Circle c( Point2d( 265,195), 40 );

	FRect_<double> rect( 0,0,200,80 );
	Polyline pl( rect, IsClosed::Yes );
	auto color_red = CvDrawParams().setColor(200,20,20);
	auto color_green = CvDrawParams().setColor(20,220,20);

// move rectangle dx=100, dy=60
	pl = Homogr().addTranslation(100, 60) * pl;
	Line2d lih( Point2d(0,100), Point2d(200,100) );
	Line2d liv( Point2d(200,0), Point2d(200,400) );

	Line2d li( Point2d(0,0), Point2d(200,80) );
	for( int i=0; i<n; i++ )
	{
		img = cv::Scalar(255,255,255);
		c.draw( img, color_green );
		lih.draw( img );
		liv.draw( img );
		li.draw( img, color_green );
		pl.draw( img, CvDrawParams().setColor(20,0,250) );
		auto inters = li.intersects( pl );
		if( inters() )
			draw( img, inters.get(), color_red );

		auto intersc = pl.intersects( c );
		if( intersc() )
			draw( img, intersc.get(), color_red );

		std::ostringstream oss;
		oss << "BUILD/showcase1_" << std::setfill('0') << std::setw(2) <<i << ".png";
		cv::imwrite( oss.str(), img );

		pl = H * pl;
		lih = H*lih;
		liv = H*liv;
	}

}

