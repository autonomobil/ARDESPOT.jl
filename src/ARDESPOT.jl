module ARDESPOT

using POMDPs
using BeliefUpdaters
using Parameters
using CPUTime
using ParticleFilters
using D3Trees
using Random
using Printf
using POMDPModelTools

using BasicPOMCP # for ExceptionRethrow and NoDecision
import BasicPOMCP.default_action

import Random.rand

export
    DESPOTSolver,
    DESPOTPlanner,

    DESPOTRandomSource,
    MemorizingSource,
    MemorizingRNG,

    ScenarioBelief,
    previous_obs,

    default_action,
    NoGap,

    IndependentBounds,
    FullyObservableValueUB,
    DefaultPolicyLB,
    bounds,
    init_bounds,
    lbound,
    ubound,
    init_bound,

    ReportWhenUsed


# include("random.jl")
include("random_2.jl")


@with_kw mutable struct DESPOTSolver <: Solver
    epsilon_0::Float64                      = 0.0
    xi::Float64                             = 0.95
    K::Int                                  = 500
    D::Int                                  = 90
    lambda::Float64                         = 0.01
    T_max::Float64                          = 1.0
    max_trials::Int                         = typemax(Int)
    bounds::Any                             = IndependentBounds(-1e6, 1e6)
    default_action::Any                     = ExceptionRethrow()
    rng::AbstractRNG                        = Random.GLOBAL_RNG
    random_source::DESPOTRandomSource       = MemorizingSource(K, D, rng)
    bounds_warnings::Bool                   = true
    tree_in_info::Bool                      = false
end

include("scenario_belief.jl")
include("default_policy_sim.jl")
include("bounds.jl")

struct DESPOTPlanner{P<:POMDP, B, RS<:DESPOTRandomSource, RNG<:AbstractRNG} <: Policy
    sol::DESPOTSolver
    pomdp::P
    bounds::B
    rs::RS
    rng::RNG
end

function DESPOTPlanner(sol::DESPOTSolver, pomdp::POMDP)
    bounds = init_bounds(sol.bounds, pomdp, sol)
    rng = deepcopy(sol.rng)
    rs = deepcopy(sol.random_source)
    Random.seed!(rs, rand(rng, UInt32))
    return DESPOTPlanner(deepcopy(sol), pomdp, bounds, rs, rng)
end

include("tree.jl")
include("planner.jl")
include("pomdps_glue.jl")

include("visualization.jl")
include("exceptions.jl")

end # module
