//
//  ViewController.swift
//  Sample3
//
//  Created by Jun Narumi on 2018/06/14.
//  Copyright © 2018年 Jun Narumi. All rights reserved.
//

import UIKit
import CIFParser

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        test()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func test() {
        print("start")
        let bundle = Bundle.main
        let path = bundle.path(forResource: "1wns", ofType: "cif")
        let h = DummyHandler()
        CIFParser.parse(path, h)
        print("done")
    }

}

