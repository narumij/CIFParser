//
//  SCNGeometry.swift
//  SwiftCrystal
//
//  Created by Jun Narumi on 2016/09/04.
//  Copyright © 2016年 zenithgear. All rights reserved.
//

import SceneKit

extension SCNGeometrySource {

    convenience init( colors: [SCNVector4] )
    {
        let data = Data( bytes: colors, count: MemoryLayout<SCNVector4>.size * colors.count )
        self.init( data: data,
                   semantic: .color,
                   vectorCount: colors.count,
                   usesFloatComponents: true,
                   componentsPerVector: 4,
                   bytesPerComponent: MemoryLayout<SCNFloat>.size,
                   dataOffset: 0,
                   dataStride: MemoryLayout<SCNVector4>.size )
    }

    convenience init( normals: [SIMD3<Float>] )
    {
        let data = Data( bytes: normals, count: MemoryLayout<SIMD3<Float>>.size * normals.count )
        self.init( data: data,
                   semantic: .normal,
                   vectorCount: normals.count,
                   usesFloatComponents: true,
                   componentsPerVector: 3,
                   bytesPerComponent: MemoryLayout<Float>.size,
                   dataOffset: 0,
                   dataStride: MemoryLayout<SIMD3<Float>>.size )
    }



    convenience init( colors: UnsafeRawPointer,
                      count: Int)
    {
        let data = Data( bytes: colors, count: MemoryLayout<SIMD4<Float>>.size*count )
        self.init( data: data,
                   semantic: SCNGeometrySource.Semantic.color,
                   vectorCount: count,
                   usesFloatComponents: true,
                   componentsPerVector: 4,
                   bytesPerComponent: MemoryLayout<Float>.size,
                   dataOffset: 0,
                   dataStride: MemoryLayout<SIMD4<Float>>.size )
    }

    convenience init( positions: UnsafeRawPointer, count: Int ) {
        let data = Data( bytes: positions, count: MemoryLayout<SIMD4<Float>>.size*count )
        self.init( data: data,
                   semantic: SCNGeometrySource.Semantic.vertex,
                   vectorCount: count,
                   usesFloatComponents: true,
                   componentsPerVector: 3,
                   bytesPerComponent: MemoryLayout<Float>.size,
                   dataOffset: 0,
                   dataStride: MemoryLayout<SIMD3<Float>>.size )
    }

    convenience init( texcoords: UnsafeRawPointer, count: Int ) {
        let data = Data( bytes: texcoords, count: MemoryLayout<SIMD2<Float>>.size*count )
        self.init( data: data,
                   semantic: SCNGeometrySource.Semantic.texcoord,
                   vectorCount: count,
                   usesFloatComponents: true,
                   componentsPerVector: 2,
                   bytesPerComponent: MemoryLayout<Float>.size,
                   dataOffset: 0,
                   dataStride: MemoryLayout<SIMD2<Float>>.size )
    }

}

extension SCNGeometry {

    static func points( _ positions: [SIMD3<Float>] ) -> SCNGeometry {
        let source = SCNGeometrySource(positions: positions, count: positions.count )
        let element = SCNGeometryElement(indices: ( 0..<positions.count ).map{ UInt16( $0 ) }, primitiveType: .point )
        return SCNGeometry( sources: [source], elements: [element] )
    }

    static func points( _ positions: [SIMD3<Float>], colors: [SIMD4<Float>] ) -> SCNGeometry {
        let vert = SCNGeometrySource(positions: positions, count: positions.count )
        let colr = SCNGeometrySource(colors: colors, count: colors.count )
        let element = SCNGeometryElement( indices: ( 0..<positions.count ).map{ UInt16( $0 ) }, primitiveType: .point )
        return SCNGeometry( sources: [vert,colr], elements: [element] )
    }

    static func lines( _ positions: [SIMD3<Float>] ) -> SCNGeometry {
        let source = SCNGeometrySource(positions: positions, count: positions.count )
        let element = SCNGeometryElement(indices: ( 0..<positions.count ).map{ UInt16( $0 ) }, primitiveType: .line )
        return SCNGeometry( sources: [source], elements: [element] )
    }

    static func lines( _ positions: [SIMD3<Float>], colors: [SIMD4<Float>] ) -> SCNGeometry {
        let vert = SCNGeometrySource(positions: positions, count: positions.count )
        let colr = SCNGeometrySource(colors: colors, count: colors.count )
        let element = SCNGeometryElement( indices: ( 0..<positions.count ).map{ UInt16( $0 ) }, primitiveType: .line )
        return SCNGeometry( sources: [vert,colr], elements: [element] )
    }

    static func lines( _ positions: [SIMD3<Float>], texcoords: [SIMD2<Float>] ) -> SCNGeometry {
        let vrt = SCNGeometrySource(positions: positions, count: positions.count )
        let tex = SCNGeometrySource(texcoords: texcoords, count: texcoords.count )
        let element = SCNGeometryElement( indices: ( 0..<positions.count ).map{ UInt16( $0 ) }, primitiveType: .line )
        return SCNGeometry( sources: [vrt,tex], elements: [element] )
    }

    static func lines( _ positions: [SIMD3<Float>], colors: [SIMD4<Float>], texcoords: [SIMD2<Float>] ) -> SCNGeometry {
        let vrt = SCNGeometrySource(positions: positions, count: positions.count )
        let clr = SCNGeometrySource(colors: colors, count: colors.count )
        let tex = SCNGeometrySource(texcoords: texcoords, count: texcoords.count )
        let element = SCNGeometryElement( indices: ( 0..<positions.count ).map{ UInt16( $0 ) }, primitiveType: .line )
        return SCNGeometry( sources: [vrt,clr,tex], elements: [element] )
    }

    static func triangleStrip( _ positions: [SIMD3<Float>] ) -> SCNGeometry {
        let source = SCNGeometrySource(positions: positions, count: positions.count )
        let element = SCNGeometryElement(indices: ( 0..<positions.count ).map{ UInt16( $0 ) }, primitiveType: .triangleStrip )
        return SCNGeometry( sources: [source], elements: [element] )
    }

    static func triangleStrip( _ positions: [SIMD3<Float>], normals: [SIMD3<Float>] ) -> SCNGeometry {
        let vert = SCNGeometrySource(positions: positions, count: positions.count )
        let norm = SCNGeometrySource(normals: normals )
        let element = SCNGeometryElement(indices: ( 0..<positions.count ).map{ UInt16( $0 ) }, primitiveType: .triangleStrip )
        return SCNGeometry( sources: [vert,norm], elements: [element] )
    }

    static func triangleStrip( _ positions: [SIMD3<Float>], normals: [SIMD3<Float>], colors: [SIMD4<Float>] ) -> SCNGeometry {
        let vert = SCNGeometrySource(positions: positions, count: positions.count )
        let norm = SCNGeometrySource(normals: normals.map{ $0.SCNVector3 } )
        let clr = SCNGeometrySource(colors: colors, count: colors.count )
        let element = SCNGeometryElement(indices: ( 0..<positions.count ).map{ UInt16( $0 ) }, primitiveType: .triangleStrip )
        return SCNGeometry( sources: [vert,norm,clr], elements: [element] )
    }


}

extension SCNGeometry {
    static func lineStrip( _ positions: [SIMD3<Float>] ) -> SCNGeometry {
        func idx(_ n: Int) -> Int {
            return n / 2 + n % 2
        }
        let indices = (0..<((positions.count-1)*2))
        let linePositions = indices.map{ positions[idx($0)] }
        return lines( linePositions )
    }

    static func lineStrip( _ positions: [SIMD3<Float>], colors: [SIMD4<Float>] ) -> SCNGeometry {
        func idx(_ n: Int) -> Int {
            return n / 2 + n % 2
        }
        let indices = (0..<((positions.count-1)*2))
        let linePositions = indices.map{ positions[idx($0)] }
        let lineColors = indices.map({ colors[idx($0)] }).map{ SIMD4<Float>($0.x,$0.y,$0.z,1) }
        return lines( linePositions, colors: lineColors )
    }
}

extension SCNGeometry {

    static func lines( _ vertices: [SCNVector3] ) -> SCNGeometry {
        let vrt = SCNGeometrySource( vertices: vertices )
        let element = SCNGeometryElement( indices: ( 0..<vertices.count ).map{ UInt16( $0 ) }, primitiveType: .line )
        return SCNGeometry( sources: [vrt], elements: [element] )
    }

    static func lines( _ vertices: [SCNVector3], colors: [SCNVector4] ) -> SCNGeometry {
        let vrt = SCNGeometrySource( vertices: vertices )
        let clr = SCNGeometrySource( colors: colors )
        let element = SCNGeometryElement( indices: ( 0..<vertices.count ).map{ UInt16( $0 ) }, primitiveType: .line )
        return SCNGeometry( sources: [vrt,clr], elements: [element] )
    }

    static func lines( _ vertices: [SCNVector3], textureCoordinates: [CGPoint] ) -> SCNGeometry {
        let vrt = SCNGeometrySource( vertices: vertices )
        let tex = SCNGeometrySource( textureCoordinates: textureCoordinates )
        let element = SCNGeometryElement( indices: ( 0..<vertices.count ).map{ UInt16( $0 ) }, primitiveType: .line )
        return SCNGeometry( sources: [vrt,tex], elements: [element] )
    }

}

