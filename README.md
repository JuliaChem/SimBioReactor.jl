# SimBioReactor.jl

[![DOI](https://zenodo.org/badge/199300314.svg)](https://zenodo.org/badge/latestdoi/199300314)

Graphical User Interface simulator of biological reactors in pure Julia. It contains two main sections: 1) New simulation and 2) Parameter Estimation. 

 - New simulation: allows to simulate batch and continuous bioreactors with different kinetic parameters and reactor properties. 
 - Parameter estimation: allows to load experimental data to fit four predifined models. 

Both sections generates .pdf reports and export figures as .png. 

This is an unregistred package. To install on Julia use:

    ] "//github.com/JuliaChem/SimBioReactor.jl"
    
To run the Graphical User Interface Simulator:
  
    SimBioReactorGUI()

# Authors
 - Kelvyn Baruc Sánchez-Sánchez (kelvyn.baruc@gmail.com)
 - Arturo Jimenez Gutierrez (arturo@iqcelaya.itc.mx)
 
# Acknowledgment
"APOYO OTORGADO POR EL FONDO SECTORIAL CONACYT-SECRETARÍA DE ENERGÍA-HIDROCARBUROS"
