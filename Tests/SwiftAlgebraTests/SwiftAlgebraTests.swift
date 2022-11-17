//
//  SwiftAlgebraTests.swift
//  SwiftAlgebraTests
//
//  Created by Jan Tomec on 10/11/2022.
//

import XCTest
@testable import SwiftAlgebra

final class LinearAlgebraTests: XCTestCase {

    func testComparison() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        let b = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
                                                                                      4.3, -9.4]])
        XCTAssert(a ≈ b)
    }
    
    func testReferencing() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        let b = a[.all, 0...2]
        a[0,0] = 100
        let c = Matrix(from: [[100.0, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        XCTAssert(b ≈ c)
    }
    
    func testCopying() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        let b = Matrix(copy: a[.all, 0...2])
        a[0,0] = 100
        let c = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        XCTAssert(b ≈ c)
    }
    
    func testArithmetics() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        let b = Matrix(from: [[-6.1, 1.0, 9.3, -3.9], [-5.1, -6.3, 1.7, 6.2], [-0.6, 0.3,
            4.3, -3.4]])
        let c = Matrix(from: [[-11.3,   1.1, -11.0],
                              [  4.8, -20.3,  19.5],
                              [ 40.5,  -7.9,  -4.9]])
        a[0..<3,0..<3] += b[0..<3,0..<3]
        XCTAssert(2*a[0..<3,0..<3].T + b.T[0..<3,0..<3] ≈ c)
        XCTAssert(-1*a ≈ -a)
    }
    
    func testMatrixMultiplication() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        let b = Matrix(from: [[-6.1, 1.0, 9.3, -3.9], [-5.1, -6.3, 1.7, 6.2], [-0.6, 0.3,
            4.3, -3.4]])
        let c = Matrix(from: [[-57.49, 63.53, -91.04],
                              [-74.85, 42.29, -64.59],
                              [-20.78, 24.62, -12.04]])
        XCTAssert(b∙a ≈ c)
    }
    
    func testMatrixPower() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9]])
        let b = Matrix(from: [[651.7790000000001, -421.98300000000006, -101.277],
                              [-770.8220000000001, 1145.1380000000001, -340.346],
                              [-365.18200000000013, 61.33800000000008, 1335.1180000000002]])
        XCTAssert(a**3 ≈ b)
    }
    
    func testInverting() throws {
        let a = Matrix(from: [[-57.49, 63.53, -91.04],
                              [-74.85, 42.29, -64.59],
                              [-20.78, 24.62, -12.04]])
        let b = Matrix(from: [[ 0.020156646023028360, -0.027530452243719080, -0.004723350790256376],
                              [ 0.008222499098030746, -0.022367978292674870,  0.057821544853750080],
                              [-0.017974848551911330,  0.001776010968341117,  0.043332031870502870]])
        XCTAssert(try invert(a) ≈ b)
        XCTAssert(a**(-1) ≈ b)
    }
    
    func testSolving() throws {
        let a = Matrix(from: [[3.5, 0.9, 6.3], [8.2, -0.7, -6.5], [-4.6, 9.3, -8.9], [0.4,
            4.3, -9.4]])
        let b = Matrix(from: [[-6.1, 1.0, 9.3, -3.9], [-5.1, -6.3, 1.7, 6.2], [-0.6, 0.3,
            4.3, -3.4]])
        let x = Matrix(from: [[-0.4494608992983296, 0.1766566088810417, 0.3831939999287645]])
        XCTAssert(try solve(A: a[0...2,0...2], b: b[.all,1]) ≈ x.T)
    }
    
    func testBlocksInit() throws {
        let I = Matrix(identity: 3)
        let O = Matrix(repeating: 0, shape: (3,1))
        let A = Matrix(blocks: [[I, O],
                                [O.T, Matrix(from: [[2]])]])
        let e = Matrix(from: [[1, 0, 0, 0],
                              [0, 1, 0, 0],
                              [0, 0, 1, 0],
                              [0, 0, 0, 2]])
        XCTAssert(e ≈ A)
    }
}


final class LieGroupsTests: XCTestCase {

    func testHatMaps() throws {
        let a = Matrix(from: [[1,2,3,4,5,6]]).T
        let b = Matrix(from: [[0, -6, 5, 1], [6, 0, -4, 2], [-5, 4, 0, 3], [0, 0, 0, 0]])
        XCTAssert(hat(a) ≈ b)
    }
    
    func testAdjointMaps() throws {
        let a = hat(Matrix(from: [[1,2,3,4,5,6]]).T)
        let b = Matrix(from: [[ 0, -6,  5,  0, -3,  2],
                              [ 6,  0, -4,  3,  0, -1],
                              [-5,  4,  0, -2,  1,  0],
                              [ 0,  0,  0,  0, -6,  5],
                              [ 0,  0,  0,  6,  0, -4],
                              [ 0,  0,  0, -5,  4,  0]])
        XCTAssert(adjoint(a) ≈ b)
        XCTAssert(tilde(Matrix(from: [[1,2,3,4,5,6]]).T) ≈ b)
        let C = Matrix(from: [[0.9948999932100924, 0.010377605632411191, 0.10033099626683739, 0.10033099626683739],
                              [-0.017386988874255382, 0.9974483144614792, 0.06924270788928673, 0.06924270788928673],
                              [-0.09935640959920278, -0.07063402352473412, 0.9925417565988158, 0.9925417565988158],
                              [0, 0, 0, 1]])
        let D = Matrix(from: [[0.9948999932100924, 0.01037760563241119, 0.1003309962668374, 0.01037760563241159, -0.9948999932100927, 0.0],
                              [-0.01738698887425538, 0.9974483144614792, 0.06924270788928673, 0.997448314461479, 0.01738698887425497, 0.0],
                              [-0.09935640959920278, -0.07063402352473412, 0.9925417565988158, -0.07063402352473423, 0.09935640959920265, 0.0],
                              [0, 0, 0, 0.9948999932100924, 0.01037760563241119, 0.1003309962668374],
                              [0, 0, 0, -0.01738698887425538, 0.9974483144614792, 0.06924270788928673],
                              [0, 0, 0, -0.09935640959920278, -0.07063402352473412, 0.9925417565988158]])
        XCTAssert(adjoint(C) ≈ D)
    }
    
    func testCoadjointMaps() throws {
        let a = hat(Matrix(from: [[1,2,3,4,5,6]]).T)
        let b = Matrix(from: [[ 0,  0,  0,  0, -3,  2],
                              [ 0,  0,  0,  3,  0, -1],
                              [ 0,  0,  0, -2,  1,  0],
                              [ 0, -3,  2,  0, -6,  5],
                              [ 3,  0, -1,  6,  0, -4],
                              [-2,  1,  0, -5,  4,  0]])
        XCTAssert(coadjoint(a) ≈ b)
        XCTAssert(check(Matrix(from: [[1,2,3,4,5,6]]).T) ≈ b)
    }
    
    func testMatrixExponential() throws {
        let A = Matrix(from: [
            [0.04223383993796454, 0.04976956277030631, 0.04379830221196449],
            [0.03929116006630112, -0.01585698710838784, -0.01820073678095158],
            [0.04059284274771685, -0.02050950600489498, -0.01088774818328189]
        ])
        let B = Matrix(from: [
            [1.045038394738093, 0.05002007747145639, 0.04407020190113505],
            [0.0394740182341173, 0.9854217505002574, -0.01710611743144869],
            [0.04086178978199471, -0.01923525295890645, 0.9902390698520096]
        ])
        XCTAssert(exp(A) ≈ B)
        let a = Matrix(from: [[-0.8582869318392046, -1.347575025923018, 1.781626098843734,
                               -0.1793278920282804, -0.3975290355042933, -1.496406970076543]]).T
        let C = Matrix(from: [
            [0.02521227505552573, 0.9889765934137569, -0.1459096942161319, -1.606278895406529],
            [-0.9310015562853204, 0.07639453709737366, 0.3569313335867125, -0.09641550289155815],
            [0.364143437920877, 0.1268431014340101, 0.9226648276800011, 1.538887042132775],
            [0.0, 0.0, 0.0, 0.9999999999999999]
        ])
        XCTAssert(exp(a) ≈ C)
        XCTAssert(exp(tilde(a)) ≈ adjoint(C))
    }
    
    func testMatrixLogarithm() throws {
        let a = Matrix(from: [[-0.8582869318392046, -1.347575025923018, 1.781626098843734,
                               -0.1793278920282804, -0.3975290355042933, -1.496406970076543]]).T
        let C = Matrix(from: [
            [0.02521227505552573, 0.9889765934137569, -0.1459096942161319, -1.606278895406529],
            [-0.9310015562853204, 0.07639453709737366, 0.3569313335867125, -0.09641550289155815],
            [0.364143437920877, 0.1268431014340101, 0.9226648276800011, 1.538887042132775],
            [0.0, 0.0, 0.0, 0.9999999999999999]
        ])
        XCTAssert(log(C) ≈ hat(a))
        let t0 = Matrix(from: [[0.7868763264210532, 1.203886777931023, 0.5319959821691604]]).T
        let R0 = Matrix(from: [[0.2907961422869064, 0.04113388905614803, 0.9559004167810422],
                               [0.7344955508816121, 0.6306550740214695, -0.2505802533043893],
                               [-0.6131507884412857, 0.7749723742057464, 0.1531794041369081]])
        let t1 = Matrix(from: [[1.398573388661105, 0.7971842294164526, -1.273935677085525]]).T
        let R1 = Matrix(from: [[0.2156630485669029, 0.9370278798262581, -0.2747147646398665],
                               [-0.1626143743060566, -0.2429421327030075, -0.9563135915727456],
                               [-0.9628322879670578, 0.2509140741090899, 0.099980561421202]])
        let t2 = Matrix(from: [[0.7592893782552697, -1.511060428787816, 1.013070434900058]]).T
        let R2 = Matrix(from: [[-0.1837111201581727, -0.8835816902078818, -0.430736138557716],
                               [0.06287615718437663, 0.4267339392460192, -0.9021888571431709],
                               [0.9809672844636333, -0.1928251586929401, -0.02283954874964771]])
        let t3 = Matrix(from: [[0.5719919837277647, -0.6343153380175943, -1.505760767702215]]).T
        let R3 = Matrix(from: [[-0.03305428768970599, 0.7182533181523285, -0.6949961043261291],
                               [-0.9990490359938253, -0.003962251934027475, 0.04342032058172771],
                               [0.02843303967455594, 0.6957704158145711, 0.7177012545147765]])
        XCTAssert(log(R0) ≈ hat(t0))
        XCTAssert(log(R1) ≈ hat(t1))
        XCTAssert(log(R2) ≈ hat(t2))
        XCTAssert(log(R3) ≈ hat(t3))
        XCTAssert(log(Matrix(identity: 6)) ≈ Matrix(repeating: 0, shape: (6,6)))
    }
    
    func testTangentApplication() throws {
        let a1 = Matrix(from: [[-0.8582869318392046, -1.347575025923018, 1.781626098843734,
                                -0.1793278920282804, -0.3975290355042933, -1.496406970076543]]).T
        let t1 = Matrix(from: [[0.6462745165802393, -0.5979580279503903, 0.2012410590456649, 0.5583987727511984, 0.6034960781415905, 0.7537280443754718],
                               [0.6189956831339359, 0.664847247770818, 0.01485542352701345, -0.4273121062671604, 0.6747567572679407, -0.1635731757580475],
                               [-0.1220496263726054, 0.1606939207197807, 0.9719370479190221, -0.4532586939885674, 0.5845337919867634, -0.2090864567824996],
                               [0, 0, 0, 0.6462745165802393, -0.5979580279503903, 0.2012410590456649],
                               [0, 0, 0, 0.6189956831339359, 0.664847247770818, 0.01485542352701345],
                               [0, 0, 0, -0.1220496263726054, 0.1606939207197807, 0.9719370479190221]])
        XCTAssert(t1 ≈ tang(adjoint(hat(a1))))
        let a2 = Matrix(from: [
            [-1.490883099064926, -1.819531184299476, -0.5032556610903036, 1.696840063768244, -1.510142861561067, 1.146198067096958],
            [0.3982622148779731, 1.007331994976521, 0.1704655436960065, -1.695423182063264, -0.9466233941985109, 0.7104376082172905],
            [-1.276383877447922, -0.0761931171456105, -0.8620470462114795, 1.991266871970826, 0.02116279922176112, 1.493854189031742],
            [0.6061510638655809, -0.08273243294353527, 1.474318093353739, -1.222630463055884, -0.6220286832779136, -1.785364877991642],
            [-1.84734763763791, 1.699742945013281, -1.048326647928877, -0.09244763015103263, 0.3846208468382768, -1.221948820167485],
            [-1.382579716726464, -1.98166863325944, -0.5469128139150454, -0.8997293979243306, -1.597453070640222, 1.36377670718979]
        ])
        let t2 = Matrix(from: [
            [3.161686710955801, 0.3099916292604631, 2.059428443277891, -4.007194876300888, 0.2207774118447712, -2.578141372468387],
            [-0.1319942664911568, 0.5939912933798162, -0.5859552726630397, 1.653844356318181, 0.6837785283270517, 0.8220955740133059],
            [0.917052178283616, -0.3528007997229992, 2.859532351290561, -4.371492548447828, -1.257583781054283, -2.888705342538899],
            [0.1839373103878249, 0.4966774440327149, -1.492637658203671, 4.143408050455589, 1.683397853005117, 2.409268300562235],
            [2.71161987548695, -0.0559383295475224, 2.101998116106948, -3.135883025909289, 1.043596570199833, -1.592891692487509],
            [1.942657096364039, 0.5727764636553025, 0.96618343864527, -0.6915289721148192, 1.161624211487807, -0.005340543541391352]
           ])
        let d = tang(a2) - t2
        XCTAssert(trace(d ∙ d.T) < 1e-10)
    }
    
    func testAdjoint() throws {
        let a = Matrix(from: [[0.32, 0.78, -0.8, -0.92, -0.13, 0.28]]).T
        let b = Matrix(from: [[-0.09, 0.83, -0.1, 0.73, -0.82, -1.00]]).T
        XCTAssert(hat(tilde(a) ∙ b) ≈ hat(a) ∙ hat(b) - hat(b) ∙ hat(a))
        XCTAssert(tilde(a).T ∙ b ≈ check(b) ∙ a)
        let A = exp(a)
        XCTAssert(hat(adjoint(A) ∙ b) ≈ A ∙ hat(b) ∙ A**(-1))
        XCTAssert(antitilde(tilde(a)) ≈ a)
        XCTAssert(anticheck(check(a)) ≈ a)
    }
}
