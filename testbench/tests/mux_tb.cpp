#include "ankit_test_bench.hpp"

#include "Vdut.h"
#include "gtest/gtest.h"

TEST(MuxTestbench, SelectsInput0) {
    TestBench::Simulator<Vdut> sim;
    sim->sel = 0;
    sim->in0 = 1;
    sim->in1 = 0;
    sim.eval();
    EXPECT_EQ(sim->out, 1u);
}

TEST(MuxTestbench, SelectsInput1) {
    TestBench::Simulator<Vdut> sim;
    sim->sel = 1;
    sim->in0 = 0;
    sim->in1 = 1;
    sim.eval();
    EXPECT_EQ(sim->out, 1u);
}

int main(int argc, char** argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
