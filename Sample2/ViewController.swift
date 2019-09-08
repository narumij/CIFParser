//
//  ViewController.swift
//  CIFTest2
//
//  Created by Jun Narumi on 2017/12/11.
//  Copyright © 2017年 Jun Narumi. All rights reserved.
//

import SceneKit
import CIFParser

func hsv2rgb( hsv: SCNVector3) -> SCNVector3
{
    var rgb = SCNVector3()

    let Hi = fmod(floor(hsv.x / 60.0), 6.0);
    let f = hsv.x / 60.0 - Hi;
    let p = hsv.z * (1.0 - hsv.y);
    let q = hsv.z * (1.0 - f * hsv.y);
    let t = hsv.z * (1.0 - (1.0 - f) * hsv.y);

    if(Hi == 0){
        rgb.x = hsv.z;
        rgb.y = t;
        rgb.z = p;
    }
    if(Hi == 1){
        rgb.x = q;
        rgb.y = hsv.z;
        rgb.z = p;
    }
    if(Hi == 2){
        rgb.x = p;
        rgb.y = hsv.z;
        rgb.z = t;
    }
    if(Hi == 3){
        rgb.x = p;
        rgb.y = q;
        rgb.z = hsv.z;
    }
    if(Hi == 4){
        rgb.x = t;
        rgb.y = p;
        rgb.z = hsv.z;
    }
    if(Hi == 5){
        rgb.x = hsv.z;
        rgb.y = p;
        rgb.z = q;
    }

    return rgb;
}

func +( l: SCNVector3, r: SCNVector3 ) -> SCNVector3 {
    return SCNVector3( l.x + r.x, l.y + r.y, l.z + r.z )
}

func -( l: SCNVector3, r: SCNVector3 ) -> SCNVector3 {
    return SCNVector3( l.x - r.x, l.y - r.y, l.z - r.z )
}

func /( l: SCNVector3, r: SCNFloat ) -> SCNVector3 {
    return SCNVector3( l.x / r, l.y / r, l.z / r )
}

extension SCNVector3 {
    var float3: SIMD3<Float> {
        return SIMD3<Float>(Float(x),Float(y),Float(z))
    }
}

extension SIMD3 where Scalar == Float {
    var SCNVector3: SceneKit.SCNVector3 {
        return SceneKit.SCNVector3( SCNFloat(x), SCNFloat(y), SCNFloat(z) )
    }
}

extension simd_quatf {
    var SCNQuaternion: SceneKit.SCNQuaternion {
        return SceneKit.SCNQuaternion( SCNFloat(vector.x), SCNFloat(vector.y), SCNFloat(vector.z), SCNFloat(vector.w) )
    }
}

class ViewController: NSViewController {

    @IBOutlet var sceneView: SCNView!

//    var positions: [SCNVector3] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

//        sceneView.removeFromSuperview()
//        sceneView = SCNView(frame: view.bounds, options: [SCNView.Option.preferredRenderingAPI.rawValue:SCNRenderingAPI.openGLLegacy.rawValue] )
        sceneView.showsStatistics = true
//        sceneView.allowsCameraControl = true
//        sceneView.backgroundColor = NSColor.black
//        sceneView.autoenablesDefaultLighting = true
//        view.addSubview(sceneView)

        var atomSites = Test.test()

        let atomCount = atomSites.filter({ $0.groupPDB == .atom }).count

        for i in 0..<atomCount {
            atomSites[i].rainbow = Double(i) / Double(atomCount-1)
        }

        let backbones = makeBackbone( atomSites  )

//        positions = mapOptional( backbones.first!, { $0.cartn } )
        let lastID = backbones.last?.last?.id.integerValue ?? -1

        let scene = SCNScene()
        let node = SCNNode()
        let rootNode = node
        scene.rootNode.addChildNode(node)

        let thickness: CGFloat = 0.3

        func spheres(_ backbone: [AtomSite], radius: CGFloat ) {
            let positions = mapOptional( backbone, { $0.cartn } )
            let colors: [SCNVector3] = mapOptional( backbone, { $0.rainbow } ).map({ hsv2rgb(hsv: SCNVector3(240 - 240 * $0,1.0,0.75)) })

            for i in 0..<positions.count {
                let p = positions[i]
                let c = colors[i]
                let node = SCNNode()
                node.geometry = SCNSphere(radius: radius)
                node.position = p
                node.geometry?.firstMaterial?.diffuse.contents = NSColor(calibratedRed: c.x, green: c.y, blue: c.z, alpha: 1.0)
                rootNode.addChildNode(node)
            }
        }

        func cylindars(_ backbone: [AtomSite] ) {
            let positions = mapOptional( backbone, { $0.cartn } )
            let colors: [SCNVector3] = mapOptional( backbone, { $0.rainbow } ).map({ hsv2rgb(hsv: SCNVector3(240 - 240 * $0,1.0,0.75)) })
            for i in 0..<(positions.count-1) {
                let p0 = positions[i]
                let p1 = positions[i+1]
                let c = colors[i]
                let q = simd_quaternion( SIMD3<Float>(0,1,0), normalize( p0.float3 - p1.float3 ) )
                let d = distance( p0.float3, p1.float3 )
                let node = SCNNode()
                node.geometry = SCNCylinder(radius: thickness, height: CGFloat( d ) )
                node.position = (p0 + p1) / SCNFloat(2.0)
                node.orientation = q.SCNQuaternion
                node.geometry?.firstMaterial?.diffuse.contents = NSColor(calibratedRed: c.x, green: c.y, blue: c.z, alpha: 1.0)
                rootNode.addChildNode(node)
            }
        }
        
        func backbone(_ backbone: [AtomSite] ) {
            spheres( backbone, radius: thickness )
            cylindars( backbone )
        }

        func lineStrip(_ backbone: [AtomSite] ) {
            let positions = mapOptional( backbone, { $0.cartn.float3 } )
            let lineStrip = SCNGeometry.lineStrip( positions )
            let lineNode = SCNNode()
            lineNode.geometry = lineStrip
            rootNode.addChildNode(lineNode)
        }

        func coloredLineStrip(_ backbone: [AtomSite] ) {
            let positions = mapOptional( backbone, { $0.cartn.float3 } )

            let colors = mapOptional( backbone, { (atomSite: AtomSite) -> SIMD4<Float> in
                let hue = atomSite.rainbow
                let color3 = hsv2rgb(hsv: SCNVector3(240 - 240 * hue,1.0,0.75)).float3
                let color4 = SIMD4<Float>(color3.x,color3.y,color3.z,1)
//                if atomSite.secondaryStructure == .helix {
//                    color4 = float4(1,0,1,1)
//                } else if atomSite.secondaryStructure == .sheet {
//                    color4 = float4(1,1,0,1)
//                }
                return color4
            })

            let lineStrip = SCNGeometry.lineStrip( positions, colors: colors )
            let lineNode = SCNNode()
            lineNode.geometry = lineStrip
            rootNode.addChildNode(lineNode)
        }


        func idx(_ count: Int ) -> (Int) -> Int {
            func i(_ n: Int ) -> Int {
                return max(0,min(n,count-1))
            }
            return i
        }

        func S(_ p:[Float] ) -> (Int,Float) -> Float {
            func pp(_ n: Int ) -> Float {
                let nn = max(0,min(n,p.count-1))
                return p[nn]
            }
            func s(_ i: Int, _ t: Float) -> Float {
                assert( 0 <= t && t <= 1 )
                let m0 = SIMD3<Float>(1,-2,1)
                let m1 = SIMD3<Float>(-2,2,0)
                let m2 = SIMD3<Float>(1,1,0)
                return 1/2 * dot( SIMD3<Float>(t*t,t,1), matrix_float3x3(rows: [m0,m1,m2]) * SIMD3<Float>(pp(i-1),pp(i),pp(i+1)) )
            }
            return s
        }

        func curve(_ backbone: [AtomSite] ) {
            let positions = mapOptional( backbone, { $0.cartn.float3 } )
            let sx = S( positions.map{ $0.x } )
            let sy = S( positions.map{ $0.y } )
            let sz = S( positions.map{ $0.z } )
            var vert: [SIMD3<Float>] = []
            for i in 1..<(positions.count-1) {
                for tt in 0...4 {
                    let t = Float(tt)/4.0
                    let p = SIMD3<Float>( sx(i,t), sy(i,t), sz(i,t) )
                    vert.append(p)
                }
            }
            let lineStrip = SCNGeometry.lineStrip( vert )
            let lineNode = SCNNode()
            lineNode.geometry = lineStrip
            rootNode.addChildNode(lineNode)
        }

        func H(_ p:[Float],_ m:[Float]) -> (Int,Float) -> Float {
            let ii = idx(p.count)
            func h(i:Int,t:Float) -> Float {
                return (2*t*t*t - 3*t*t + 1) * p[ii(i)] + (t*t*t - 2*t*t + t) * m[ii(i)] + (-2*t*t*t + 3*t*t) * p[ii(i+1)] + (t*t*t - t*t) * m[ii(i+1)]
            }
            return h
        }

        func curve2(_ backbone: [AtomSite]) {
            let positions = mapOptional( backbone, { $0.cartn.float3 } )
            let posIdx = idx(positions.count)
            let tangents = (0..<positions.count).map{ (positions[posIdx($0+1)] - positions[posIdx($0-1)]) }
            let hx = H( positions.map{ $0.x }, tangents.map{ $0.x } )
            let hy = H( positions.map{ $0.y }, tangents.map{ $0.y } )
            let hz = H( positions.map{ $0.z }, tangents.map{ $0.z } )
            var vert: [SIMD3<Float>] = []
            for i in 0..<positions.count {
                for tt in 0...4 {
                    let t = Float(tt)/4.0
                    let p = SIMD3<Float>( hx(i,t), hy(i,t), hz(i,t) )
                    vert.append(p)
                }
            }
            let lineStrip = SCNGeometry.lineStrip( vert )
            let lineNode = SCNNode()
            lineNode.geometry = lineStrip
            rootNode.addChildNode(lineNode)
        }

        func ribbon(_ backbone: [AtomSite] ) {

            var vert: [SIMD3<Float>] = []
            var hues: [Float] = []
            var second: [SecondaryStructure] = []

            let positions = mapOptional( backbone, { $0.cartn.float3 } )
            let posIdx = idx(positions.count)

            #if false
            let sx = S( positions.map{ $0.x } )
            let sy = S( positions.map{ $0.y } )
            let sz = S( positions.map{ $0.z } )
            for i in 0..<positions.count {
                func isSheetLast(_ n: Int) -> Bool {
                    return backbone[posIdx(n-1)].secondaryStructure == .sheet
                        && backbone[posIdx(n)].secondaryStructure != .sheet
                }
                let res = isSheetLast(i) ? 1 : 32
                let h = Float(backbone[i].rainbow)
                let s = isSheetLast(i) ? .sheet : backbone[i].secondaryStructure
                for tt in 0..<res {
                    let t = Float(tt)/Float(res)
                    let p = float3( sx(i,t), sy(i,t), sz(i,t) )
                    vert.append(p)
                    hues.append(h)
                    second.append(s)
                }
            }
            #else
                let tangents = (0..<positions.count).map{ ( i: Int) -> SIMD3<Float> in
                    let t: SIMD3<Float> = (positions[posIdx(i+1)] - positions[posIdx(i-1)])
                    if backbone[i].secondaryStructure == .sheet {
                        return t * 0.5
                    }
                    return t
                }
                let hx = H( positions.map{ $0.x }, tangents.map{ $0.x } )
                let hy = H( positions.map{ $0.y }, tangents.map{ $0.y } )
                let hz = H( positions.map{ $0.z }, tangents.map{ $0.z } )
                for i in 0..<positions.count {
                    func isSheetLast(_ n: Int) -> Bool {
                        return backbone[posIdx(n-1)].secondaryStructure == .sheet
                            && backbone[posIdx(n)].secondaryStructure != .sheet
                    }
                    let res = isSheetLast(i) ? 1 : 4
                    let h = Float(backbone[i].rainbow)
                    let s = isSheetLast(i) ? .sheet : backbone[i].secondaryStructure
                    for tt in 0..<res {
                        let t = Float(tt)/Float(res)
                        let p = SIMD3<Float>( hx(i,t), hy(i,t), hz(i,t) )
                        vert.append(p)
                        hues.append(h)
                        second.append(s)
                    }
                }
            #endif

            var vert2: [SIMD3<Float>] = []
            var vert3: [SIMD3<Float>] = []
            var vert4: [SIMD3<Float>] = []

            func v(_ i: Int ) -> SIMD3<Float> {
                var offset = 0
                if i == 0 {
                    offset = 1
                }
                if i == vert.count - 1 {
                    offset = -1
                }
                let ii = i + offset
                let v0 = normalize(vert[ii]-vert[ii-1])
                let v1 = normalize(vert[ii+1]-vert[ii])

//                if acos( dot( v0, v1 ) ) < (.pi/180.0) {
//                    return float3()
//                }

//                if length_squared( cross( v0, v1 ) ) < 0.001 {
//                    return float3()
//                }

                return normalize( cross( v0 , v1 ) )
            }

            var lastC = SIMD3<Float>()
            var cArray: [SIMD3<Float>] = []
            for i in 0..<vert.count {
                var c = v(i)
                if length_squared(c).isNaN {
                    c = SIMD3<Float>()
                }
                if length_squared(c).isInfinite {
                    c = SIMD3<Float>()
                }

                let d0 = distance_squared(lastC,c)
                let d1 = distance_squared(lastC,-c)
                if d1 < d0 {
                    c = -c
                }

                cArray.append(c)
                lastC = normalize( lastC * 0.6666 + c * 0.3333 )
            }
            
            for i in 1..<(cArray.count-1) {
                let c0 = cArray[i-1]
                let c1 = cArray[i]
                let c2 = cArray[i+1]
                if acos( dot(c0,c1) ) > acos( dot(c0,c2) ) {
                    cArray[i] = normalize( c0 + c2 )
                }
            }

            let cArray2 = cArray



            let _idx = idx(cArray.count)

            for i in 0..<cArray.count {
                let b = 7
                let m = [0] + (1...b) + (1...b).map{ -$0 }
                let c = normalize( m.map({ cArray2[_idx($0+i)]}).reduce(SIMD3<Float>()) { $0 + $1 } )
                cArray[i] = c
            }

            var normal: [SIMD3<Float>] = []
            var color: [SIMD4<Float>] = []

            for i in 0..<vert.count {
                var c = cArray[i]
                if length_squared(c) < 0.1 {
                    continue
                }

                let nor = normalize( cross( normalize( vert[_idx(i-1)] - vert[_idx(i+1)] ), c ) )
                let hue = hues[i]
                let color3 = hsv2rgb(hsv: SCNVector3(240 - 240 * hue,1.0,0.75)).float3
                var color4 = SIMD4<Float>(color3.x,color3.y,color3.z,1)

                func isSheetBegin(_ n: Int) -> Bool {
                    return  ( second[_idx(n-1)] != .sheet && second[_idx(n)] == .sheet )
                            || ( second[_idx(n-1)] != .helix && second[_idx(n)] == .helix )
                }

                func isSheetLast(_ n: Int) -> Bool {
                    return (second[_idx(n)] == .sheet && second[_idx(n+1)] != .sheet)
                }

                var width: Float = 0.25

//                color4 = float4(0,1,1,1)
                if second[i] == .helix {
                    width = 1.5
//                    color4 = float4(1,0,1,1)
                } else if second[i] == .sheet {
                    width = 1.2
//                    color4 = float4(1,1,0,1)
                }

                func issue(_ width: Float ) {
                    vert2.append(vert[i] - c * width )
                    vert3.append(vert[i] + c * width )
                    vert4.append(vert[i] - c * width )
                    vert4.append(vert[i] + c * width )
                    normal.append(nor)
                    normal.append(nor)
                    color.append(color4)
                    color.append(color4)
                }

                if isSheetBegin(i) {
                    issue( 0.2 )
                }

                issue( width )

                if isSheetLast(i) {
                    issue( width * 1.8 )
                }
            }

            func add(_ g: SCNGeometry ) -> SCNNode {
                let node = SCNNode()
                node.geometry = g
                rootNode.addChildNode(node)
                return node
            }

            let edge = NSColor(calibratedWhite: 0.25, alpha: 1.0)
//            let r = add( SCNGeometry.lineStrip( vert ) )
//            r.geometry?.firstMaterial?.diffuse.contents = NSColor.red
            let g = add( SCNGeometry.lineStrip( vert2 ) )
            g.geometry?.firstMaterial?.diffuse.contents = edge
            let b = add( SCNGeometry.lineStrip( vert3 ) )
            b.geometry?.firstMaterial?.diffuse.contents = edge

//            _ = add( SCNGeometry.lines( vert4 ) )
//            let n = add( SCNGeometry.triangleStrip( vert4 ) )
//            let n = add( SCNGeometry.triangleStrip( vert4, normals: normal ) )
            let n = add( SCNGeometry.triangleStrip( vert4, normals: normal, colors: color ) )
            n.geometry?.firstMaterial?.isDoubleSided = true
        }

//        spheres( atomSites, radius: 3.0 )
//        _ = backbones.map( backbone )
//        _ = backbones.map( lineStrip )
//        _ = backbones.map( coloredLineStrip )
//        _ = backbones.map( curve )
//        _ = backbones.map( curve2 )
        _ = backbones.map( ribbon )

        sceneView.scene = scene

//        Check(sceneView)
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func export(_ sender: AnyObject) {
        let savePanel = NSSavePanel()
        let scene = sceneView.scene
        savePanel.begin { (response) in
            if response == .OK {
                _ = savePanel.url.map{ scene?.write( to: $0, options: nil, delegate: nil, progressHandler: nil ); }
            }
        }
    }

}

