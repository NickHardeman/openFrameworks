//
//  ofxAssimpBounds.cpp
//
//  Created by Nick Hardeman on 10/18/23.
//

#include "ofxAssimpBounds.h"
#include "ofGraphics.h"

//--------------------------------------------------------------
using namespace ofx::assimp;

ofMesh Bounds::mLinesMesh;

//--------------------------------------------------------------
void Bounds::clear() {
	min = glm::vec3( 0.f, 0.f, 0.f);
	max = glm::vec3(0.f, 0.f, 0.f );
	center = glm::vec3( 0.f,0.f,0.f );
	radius = 0.f;
	_resetMinMax();
	bCalced = false;
	mBoundingVerts.assign( 8, glm::vec3(0.f, 0.f, 0.f));
}

//--------------------------------------------------------------
void Bounds::include( glm::mat4& amat, const std::vector<aiVector3D>& averts) {
	size_t numVerts = averts.size();
	glm::vec4 tmp;
	for( size_t i = 0; i < numVerts; i++ ) {
		tmp = amat * glm::vec4(averts[i].x,averts[i].y,averts[i].z,1.0f);
		_calcMin(tmp);
		_calcMax(tmp);
	}
	update();
}

//--------------------------------------------------------------
void Bounds::include( const std::vector<aiVector3D>& averts) {
	size_t numVerts = averts.size();
	glm::vec3 tmp;
	for( size_t i = 0; i < numVerts; i++ ) {
		tmp = glm::vec3(averts[i].x,averts[i].y,averts[i].z);
		_calcMin(tmp);
		_calcMax(tmp);
	}
	update();
}

//--------------------------------------------------------------
void Bounds::include( const glm::mat4& amat, const std::vector<glm::vec3>& averts) {
	size_t numVerts = averts.size();
	glm::vec4 tmp;
	for( size_t i = 0; i < numVerts; i++ ) {
		tmp = amat * glm::vec4(averts[i].x,averts[i].y,averts[i].z,1.0f);
		_calcMin(tmp);
		_calcMax(tmp);
	}
	update();
}

//--------------------------------------------------------------
void Bounds::include( const std::vector<glm::vec3>& averts) {
	for( auto& vert : averts ) {
		_calcMin(vert);
		_calcMax(vert);
	}
	update();
}

//--------------------------------------------------------------
void Bounds::update() {
	if( mBoundingVerts.size() != 8 ) {
		mBoundingVerts.assign( 8, glm::vec3(0.f, 0.f, 0.f));
	}
	mBoundingVerts[0] = glm::vec3(min.x, min.y, min.z);
	mBoundingVerts[1] = glm::vec3(max.x, min.y, min.z);
	mBoundingVerts[2] = glm::vec3(max.x, min.y, max.z);
	mBoundingVerts[3] = glm::vec3(min.x, min.y, max.z);
	
	mBoundingVerts[4] = glm::vec3(min.x, max.y, min.z);
	mBoundingVerts[5] = glm::vec3(max.x, max.y, min.z);
	mBoundingVerts[6] = glm::vec3(max.x, max.y, max.z);
	mBoundingVerts[7] = glm::vec3(min.x, max.y, max.z);
	
	_calcCenter();
	_calcRadius();
	bCalced = true;
}

//--------------------------------------------------------------
void Bounds::draw() {
	if( mLinesMesh.getNumVertices() < 1 ) {
		mLinesMesh.setMode( OF_PRIMITIVE_LINES );
		mLinesMesh.getVertices().resize(8);
		mLinesMesh.getVertices()[0] = glm::vec3( -0.5, -0.5, 0.5 );
		mLinesMesh.getVertices()[1] = glm::vec3( 0.5, -0.5, 0.5 );
		mLinesMesh.getVertices()[2] = glm::vec3( -0.5, 0.5, 0.5 );
		mLinesMesh.getVertices()[3] = glm::vec3( 0.5, 0.5, 0.5 );
		
		mLinesMesh.getVertices()[4] = glm::vec3( -0.5, -0.5, -0.5 );
		mLinesMesh.getVertices()[5] = glm::vec3( 0.5, -0.5, -0.5 );
		mLinesMesh.getVertices()[6] = glm::vec3( -0.5, 0.5, -0.5 );
		mLinesMesh.getVertices()[7] = glm::vec3( 0.5, 0.5, -0.5 );
		
		// front
		mLinesMesh.addIndex(1);
		mLinesMesh.addIndex(0);
		
		mLinesMesh.addIndex(0);
		mLinesMesh.addIndex(2);
		
		mLinesMesh.addIndex(2);
		mLinesMesh.addIndex(3);
		
		mLinesMesh.addIndex(3);
		mLinesMesh.addIndex(1);
		
		// left
		mLinesMesh.addIndex(0);
		mLinesMesh.addIndex(4);
		
		mLinesMesh.addIndex(4);
		mLinesMesh.addIndex(6);
		
		mLinesMesh.addIndex(6);
		mLinesMesh.addIndex(2);
		
		//        mLinesMesh.addIndex(2);
		//        mLinesMesh.addIndex(0);
		
		// right
		mLinesMesh.addIndex(5);
		mLinesMesh.addIndex(1);
		
		//        mLinesMesh.addIndex(1);
		//        mLinesMesh.addIndex(3);
		
		mLinesMesh.addIndex(3);
		mLinesMesh.addIndex(7);
		
		mLinesMesh.addIndex(7);
		mLinesMesh.addIndex(5);
		
		// back
		mLinesMesh.addIndex(5);
		mLinesMesh.addIndex(4);
		
		//        mLinesMesh.addIndex(4);
		//        mLinesMesh.addIndex(6);
		
		mLinesMesh.addIndex(6);
		mLinesMesh.addIndex(7);
		
		//        mLinesMesh.addIndex(7);
		//        mLinesMesh.addIndex(5);
	}
	
	ofPushMatrix(); {
		ofTranslate( center );
		ofScale( fabs(max.x-min.x), fabs(max.y-min.y), fabs(max.z-min.z) );
		mLinesMesh.draw();
	} ofPopMatrix();
	//
	//    ofPushMatrix(); {
	//        ofTranslate( center );
	//        ofDrawSphere(0, 0, 0, 10);
	//    } ofPopMatrix();
	
	//    cout << "center: " << center << " min.x: " << min.x << " max.x: " << max.x << endl;
	
	//    ofDrawSphere(min, 5);
	//    ofDrawSphere(max, 5);
}

//--------------------------------------------------------------
float Bounds::getWidth() {
	return max.x-min.x;
}

//--------------------------------------------------------------
float Bounds::getHeight() {
	return max.y-min.y;
}

//--------------------------------------------------------------
float Bounds::getDepth() {
	return max.z-min.z;
}

//--------------------------------------------------------------
glm::vec3 Bounds::getDimensions() {
	return glm::vec3( getWidth(), getHeight(), getDepth() );
}

//--------------------------------------------------------------
void Bounds::_resetMinMax() {
	min.x = min.y = min.z =  1e10f;
	max.x = max.y = max.z = -1e10f;
}

//--------------------------------------------------------------
void Bounds::_calcMin( const glm::vec3& apt ) {
	min.x = std::min(min.x,apt.x);
	min.y = std::min(min.y,apt.y);
	min.z = std::min(min.z,apt.z);
}

//--------------------------------------------------------------
void Bounds::_calcMax( const glm::vec3& apt ) {
	max.x = std::max(max.x,apt.x);
	max.y = std::max(max.y,apt.y);
	max.z = std::max(max.z,apt.z);
}

//--------------------------------------------------------------
void Bounds::_calcCenter() {
	center = (max + min) * 0.5f;
}

//--------------------------------------------------------------
void Bounds::_calcRadius() {
	radius = glm::distance( min,max )/2.f;
}
