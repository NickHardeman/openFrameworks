//
//  ofxAssimpMeshHelper.h
//  Created by Lukasz Karluk on 4/12/12.
//

#pragma once

#include "ofMaterial.h"
#include <assimp/cimport.h>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include "ofxAssimpTexture.h"
#include "ofVbo.h"
#include "ofMesh.h"
#include "glm/mat4x4.hpp"
#include "ofxAssimpNode.h"
#include "ofxAssimpBounds.h"
#include <unordered_map>
#include "ofxAssimpBone.h"
#include "ofxAssimpSrcMesh.h"

struct aiMesh;
namespace ofx::assimp {

class Mesh : public ofx::assimp::Node {
public:
	
	virtual NodeType getType() override { return OFX_ASSIMP_MESH; }
	
//	void addTexture( std::shared_ptr<ofx::assimp::Texture> aAssimpTex);
	bool hasTexture();
//	bool hasTexture(aiTextureType aTexType);
//	bool hasTexture( ofMaterialTextureType aType );
	
	ofTexture& getTexture();
//	ofTexture& getTexture(aiTextureType aTexType);
//	ofTexture& getTexture(ofMaterialTextureType aType);
//	std::vector<std::shared_ptr<ofx::assimp::Texture>> & getAllMeshTextures(){ return meshTextures; }
	
	size_t getNumVertices();
	bool hasNormals();
	aiMesh* getAiMesh();
	std::size_t getNumIndices();
	
	void setSrcMesh( std::shared_ptr<ofx::assimp::SrcMesh> aSrcMesh );
//	void setup(aiMesh* amesh);
//	aiMesh* getAiMesh() { return mAiMesh; }
//	const aiMesh* getAiMesh() const { return mAiMesh; }
	
	ofMesh& getStaticMesh();
	ofMesh& getMesh();
	
	ofMesh getTransformedStaticMesh();
	ofMesh getTransformedMesh();
	
	Bounds getLocalBounds();
	Bounds getModelBounds();
	Bounds getGlobalBounds();
	
	void recalculateBounds(bool abForce=false);
	
//	ofVbo vbo;
	
//	std::vector<ofIndexType> indices;
	
	std::shared_ptr<ofMaterial> material;
	std::shared_ptr<ofVbo> vbo;
	
	ofBlendMode blendMode = OF_BLENDMODE_ALPHA;
	bool twoSided = false;
	
	bool hasChanged = false;
	bool validCache = false;
	
	std::vector<aiVector3D> animatedPos;
	std::vector<aiVector3D> animatedNorm;
	
	std::vector< std::shared_ptr<ofx::assimp::Bone> > mBones;
	
	std::shared_ptr<ofx::assimp::SrcMesh> getSrcMesh() { return mSrcMesh; }
	
protected:
	virtual void onPositionChanged() override;
	virtual void onOrientationChanged() override;
	virtual void onScaleChanged() override;
	
	std::shared_ptr<ofx::assimp::SrcMesh> mSrcMesh;
	
//	static std::unordered_map< int, ofMaterialTextureType > sAiTexTypeToOfTexTypeMap;
//	
////	std::string mName = "";
//	void _initTextureTypeMap();
//	ofMaterialTextureType _getOfTypeForAiType(aiTextureType aTexType);
//	aiTextureType _getAiTypeForOfType(ofMaterialTextureType aTexType);
//	//for normal, specular, etc - we include the diffuse too with a null deleter
//	std::vector<std::shared_ptr<ofx::assimp::Texture>> meshTextures;
//	static ofTexture sDummyTex;
	
	// calculate the local bounds for all of the vertices
	// has no position, scale or rotations applied
	// TODO: Do this for animated vertices as well
	// to account for all animated frames
	Bounds mLocalBounds;
	// bounds relative to local translation, rotation and scale
	Bounds mModelBounds;
	// global bounds, should include all transformations
	Bounds mGlobalBounds;
	// should be updated when any transformations are changed or vertices, bones, etc.
	bool bBoundsDirty = false;
	
	
//	aiMesh* mAiMesh = nullptr; // pointer to the aiMesh we represent.
	
	ofMesh mMesh;
	ofMesh mAnimatedMesh;
	bool mBInitedAnimatedMesh = false;
	
};
}
