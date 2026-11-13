#pragma once

#include <cstddef>
#include <cstdint>
#include <memory>
#include <string>

#include "verilated.h"
#include "verilated_vcd_c.h"

namespace TestBench {

struct Config {
    bool trace = false;
    std::string vcd_file = "waveform.vcd";
    int trace_levels = 99;
};

// Use eval() for combinational modules; tick() requires a `clk` input.
template <typename Module>
class Simulator {
public:
    explicit Simulator(const Config& config = {}) {
        if (config.trace) Verilated::traceEverOn(true);
        top_ = std::make_unique<Module>();
        top_->eval();

        if (config.trace) {
            trace_ = std::make_unique<VerilatedVcdC>();
            top_->trace(trace_.get(), config.trace_levels);
            trace_->open(config.vcd_file.c_str());
        }
    }

    ~Simulator() {
        top_->final();
        if (trace_) trace_->close();
    }

    Simulator(const Simulator&) = delete;
    Simulator& operator=(const Simulator&) = delete;

    Module* operator->() { return top_.get(); }
    void eval() { top_->eval(); }

    // One rising edge is one CPU cycle. Observe outputs after tick() returns.
    void tick() {
        top_->clk = 0;
        top_->eval();
        if (trace_) trace_->dump(static_cast<std::uint64_t>(2 * cycles_));

        top_->clk = 1;
        top_->eval();
        if (trace_) trace_->dump(static_cast<std::uint64_t>(2 * cycles_ + 1));
        ++cycles_;
    }

    template <typename Check>
    void run(std::size_t cycles, Check&& check) {
        for (std::size_t i = 0; i < cycles && !Verilated::gotFinish(); ++i) {
            tick();
            check(i);
        }
    }

private:
    std::unique_ptr<Module> top_;
    std::unique_ptr<VerilatedVcdC> trace_;
    std::size_t cycles_ = 0;
};

}  // namespace TestBench
