#include "test_bench.hpp"

#include "Vdut.h"
#include "gtest/gtest.h"

class CpuTestbench : public ::testing::Test {
protected:
    TestBench::Simulator<Vdut> sim;

    void SetUp() override {
        sim->rst = 1;
        sim.tick();
        sim->rst = 0;
        sim.eval();
    }
};

TEST_F(CpuTestbench, CounterProgram) {
    EXPECT_EQ(sim->a0, 0u);

    unsigned last = 0;
    sim.run(800, [&](std::size_t) {
        if (last < 254 && sim->a0 != last) {
            ASSERT_EQ(sim->a0, last + 1);
            last = sim->a0;
        }
    });
    ASSERT_EQ(last, 254u);
}

int main(int argc, char** argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
