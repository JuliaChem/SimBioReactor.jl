using SimBioReactor
using Test
using Gtk

@testset "mainGUI" begin
    w =SimBioReactorGUI()
    destroy(w)
end
