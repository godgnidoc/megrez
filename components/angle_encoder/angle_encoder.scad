include <../../third-party/solidboredom/constructive-compiled.scad>
include <params.scad>

$fn = 100;

$skinThick = 1.5;

/**
 * PCB 支撑层的高度
 */
H_PCBRing = H_AIR + H_AS5600;

/**
 * PCB 支撑层外径，即PCB板直径
 */
OD_PCBRing = R_SO * 2 - D_SO - S_WallD;

/**
 * PCB 支撑层内径
 */
ID_PCBRing = R_SI * 2 - D_SI - S_WallD;

assemble("Shell") mount();

/**
 * 螺母
 * @param l 边长
 * @param h 高度
 */
module nut(l = 4, h = 1.6) g() {
  pieces(n = 3) turnXY(every(60)) box(x = l / sqrt(3), y = l, h = h);
}

module mount() {
  applyTo("Shell", TOUP()) {
    add() {
      /**
       * 最外层管壳
       */
      tube(dOuter = D_Shell, dInner = OD_PCBRing - thetaD, h = H_Shell);

      /**
       * 电路板支撑环
       */
      Z(H_L1 + H_L2)
      tube(dOuter = OD_PCBRing + thetaD, dInner = ID_PCBRing, h = H_PCBRing);
    }

    remove(add = "Motor") {
      /**
       * 一级凸起
       */
      tube(d = D_L1 + thetaD, h = H_L1 + thetaR);

      /**
       * 二级凸起
       */
      tube(d = D_L2 + thetaD, h = H_L1 + H_L2 + thetaR);
    }

    remove(add = "Screws") {
      /**
       * 外圈螺孔
       */
      pieces(n = 4) turnXY(span(360, allButLast = true) + 45) X(R_SO)
          tube(d = D_SO + thetaD, h = H_Shell + thetaR);

      /**
       * 内圈螺孔
       */
      two() X(sides(X_SI / 2)) two() Y(sides(Y_SI / 2)) {
        tube(d = D_SI + thetaD, h = H_Shell + thetaR);
        // Z(TOP_PCBRing + H_PCB) tube(d = D_SIH + thetaD, h = D_SI);
      }
    }

    /**
     * 电机 PogoPin 触点焊盘留孔
     */
    remove(add = "PogoPin") {
      X(R_Q) {
        chamfer(0, 0, -1, fnCorner = 60) box(x = X_Q, y = Y_Q, h = H_L1 + H_L2);
      }
      X(R_Q - X_Q / 2) {
        chamfer(0, 0, -1, fnCorner = 60)
            box(x = X_Q, y = Y_Q, h = H_L1 + H_L2 + H_PCBRing);
      }
    }
  }

  applyTo("WeightRing", TOUP(), Z(H_L1 + H_L2)) {
    add(remove = "Shell") {
      difference() {
        Z(H_PCBRing * 0.25) {
          tubeShell(dOuter = R_SO * 2, dInner = R_SI * 2, h = H_PCBRing * 0.5);
        }
        pieces(n = 4) turnXY(span(360, allButLast = true) + 45)
            X((R_SI + R_SO) / 2)
                box(x = D_SO + D_SI + S_WallD, y = D_SO + D_SI, h = H_PCBRing);
        X(R_Q + X_Q * 0.25) {
          Y(Y_Q * 0.4)
          chamfer(0, 0, -1, fnCorner = 60)
              box(x = X_Q * 0.5, y = Y_Q * 0.4, h = H_PCBRing);
          Y(Y_Q * -0.4)
          chamfer(0, 0, -1, fnCorner = 60)
              box(x = X_Q * 0.5, y = Y_Q * 0.4, h = H_PCBRing);
        }
      }
      pieces(n = 4) turnXY(span(360, allButLast = true) + 45) Z(0.5) {
        hull() {
          X(R_SO)
          nut(l = 5 + thetaD, h = 1.9 + thetaD);
          X(D_Shell / 2)
          nut(l = 5 + thetaD, h = 1.9 + thetaD);
        }
      }
    }
  }
}

/**
 * 方形开槽
 */
// g(TORIGHT(), turnXZ(90), Z(R_Q)) {
//   chamfer(0, 0, -1, fnCorner = 60)
//       box(x = H_Q + delta * 2, y = Y_Q, h = X_Q * 2);
//   TODOWN() box(x = H_Q + delta * 2, y = Y_Q, h = X_Q);
//   TOUP() box(x = H_Q / 2 + delta * 2, y = Y_Q, h = X_Q);
// }