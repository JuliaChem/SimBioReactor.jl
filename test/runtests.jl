using SimBioReactor
using Base.Test

@testset "mainGUI" begin
    w =SimBioReactorGUI()
    destroy(w)
end
