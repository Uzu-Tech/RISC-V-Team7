#include "ankit_test_bench.hpp"

#include "Vdut.h"
#include "gtest/gtest.h"

class CpuTestbench : public ::testing::Test {
protected:
    TestBench::Simulator<Vdut> sim;

    void SetUp() override {
        // Confirm with the team: this assumes active-high, synchronous reset.
        sim->rst = 1;
        sim.tick();
        sim->rst = 0;
        sim.eval();
    }
};

TEST_F(CpuTestbench, CounterProgram) {
    // The supplied program repeatedly writes 0..254 to a0.
    EXPECT_EQ(sim->a0, 0u);

    for (unsigned expected = 1; expected <= 254; ++expected) {
        bool seen = false;
        for (int instruction = 0; instruction < 10; ++instruction) {
            sim.tick();
            if (sim->a0 == expected) {
                seen = true;
                break;
            }
            ASSERT_EQ(sim->a0, expected - 1)
                << "Unexpected a0 while waiting for " << expected;
        }
        ASSERT_TRUE(seen) << "a0 never reached " << expected;
    }
}

int main(int argc, char** argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
