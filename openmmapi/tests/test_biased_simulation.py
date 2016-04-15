
# no biased potential

from simtk.openmm.app import *
from simtk.openmm import *
from simtk.unit import *
from sys import stdout
from ANN import *

############################ PARAMETERS BEGIN ###############################################################
record_interval = 50
total_number_of_steps = 10000

input_pdb_file_of_molecule = './dependency/alanine_dipeptide.pdb'
force_field_file = 'amber99sb.xml'
water_field_file = 'amber99_obc.xml'

pdb_reporter_file = './dependency/test_biased_output.pdb'
state_data_reporter_file = './dependency/test_biased_report.txt'


############################ PARAMETERS END ###############################################################


pdb = PDBFile(input_pdb_file_of_molecule) 
forcefield = ForceField(force_field_file) # without water
system = forcefield.createSystem(pdb.topology,  nonbondedMethod=NoCutoff, \
                                 constraints=AllBonds)  # what does it mean by topology? 

platform = Platform.getPlatformByName('Reference')
platform.loadPluginsFromDirectory('.')  # load the plugin from the current directory

force = ANN_Force()

force.set_layer_types(['Tanh', 'Tanh'])
list_of_index_of_atoms_forming_dihedrals = [[2,5,7,9],
											[5,7,9,15],
											[7,9,15,17],
											[9,15,17,19]]

force.set_list_of_index_of_atoms_forming_dihedrals(list_of_index_of_atoms_forming_dihedrals)
force.set_num_of_nodes([8, 15, 2])
force.set_potential_center(
	[-0.2,-0.7]
	)
force.set_force_constant(1000)
force.set_values_of_biased_nodes([
	[0.018419916290355859, -0.027179921876571329, 0.015491912248851143, 0.022409446469199863, 0.018378553946430946, 0.010598346612722836, -0.016990671659658552, -0.01267146975457502, -0.025749522490845427, -0.027830208745939236, -0.002763919236192079, 0.020823987361138243, -0.0082493773779556689, -0.0029774140453083377, 0.0042951352249547357]
,
[-0.031119236542918722, -0.027724986802864001]
	])
force.set_coeffients_of_connections([
									[0.03515557798267728, 0.04967823281764687, 0.1035377288351734, -0.013688735541306519, 0.0060582557112433995, 0.19107982500429405, -0.19219114018499839, -0.0074531990447364947, -0.043605083269797187, -0.034451322166260075, -0.072555806530318318, 0.017341039284811059, -0.015911636481423522, -0.25501960271961804, 0.24777848324814419, 0.0085502655092732239, 0.023973150672977971, 0.089757137505057552, 0.18042273295411859, -0.014922967302649415, -0.00068883805242394062, 0.1091084313527881, -0.11920989362486452, -0.0054557417261226534, 0.029647786123846925, -0.10885867806499036, -0.19750483594197768, -0.021067476175841135, 0.023883374367726511, 0.21084194503108064, -0.18426957515428974, 0.0016261222552701024, 0.035907725278727883, 0.057194212946742311, 0.11348591782225285, -0.016885159682803439, 0.0085290889516621612, 0.19649028902420876, -0.19889622771782964, -0.0093753363415333985, 0.020449967903263058, -0.097956290366006143, -0.17948354240966827, -0.0082637789697431168, 0.018086999034275797, 0.11541034888078155, -0.089738560372765411, 0.0048676101101267849, -0.0361286822848274, -0.043628641103327356, -0.090168135879889408, 0.014701236401513192, -0.0084993269101378346, -0.19001098991711057, 0.18884107072419803, 0.004938441989430083, -0.022469531507342828, 0.16990108438309143, 0.31511510359835665, 0.010252428788005639, -0.023984344781623618, -0.14445696400508964, 0.11045221600622858, -0.0075810295855754046, -0.0257075918213284, -0.11545763649433935, -0.23898259915856948, 0.024277559028185874, -0.0057324466763098991, -0.15904495166082977, 0.17446628337176076, 0.010909026332924376, -0.0070466254198546276, -0.15704272680998924, -0.32028223520542842, 0.022156886529859289, 0.0081378885568253196, -0.085160087134678972, 0.11897108311579653, 0.010024699608460223, -0.016582365250590366, 0.12820094235205051, 0.22998706022946658, 0.0064502758649851279, -0.018571951325665689, -0.077226762131139506, 0.050114885115655941, -0.0036284479919746521, 0.027455004437523692, -0.14523241990573069, -0.26469514390669313, -0.022304431382626583, 0.023641966984853168, 0.19846016734705219, -0.16876430848456159, 0.007494877788618323, -0.019141028106150294, 0.072971611930716426, 0.13324967028243709, 0.0074416251147908204, -0.0092205004861796863, -0.1075814540948344, 0.093682570955162664, 0.00019848779153204809, -0.013068942060505559, -0.022034503186638282, -0.052835561128481812, 0.0028511535863189287, 0.001520413535813015, -0.061002917213336796, 0.067735902048583096, -0.00062981335657270551, 0.001887810613778459, 0.099037594028651588, 0.1874143031418907, -0.004641357791237981, -0.0065439833911653715, 0.019563977711380354, -0.037636048411345734, -0.0083388337910155642]
,
[-0.29639949732892373, 0.35075525881714537, -0.26237540986962316, -0.08449815112928466, -0.31262010049923933, 0.014712691660711043, 0.28371650957951872, -0.087933029956506231, 0.37342875808851184, 0.36120320711578374, -0.097802489299170847, -0.017730566322245435, 0.016583376187015011, 0.10788838122420535, -0.16919742650168318, -0.088514677672194911, 0.1770548982885814, 0.052625455133877334, -0.37336324059096843, -0.084861123510576175, -0.25840429199320858, 0.098263977269458222, 0.416582802156298, -0.054420996093528004, -0.19165748035121646, 0.26976994428243994, -0.42600430590732891, 0.21246362412049166, 0.013810390450139111, 0.14069628175648147]
])

system.addForce(force)

integrator = LangevinIntegrator(300*kelvin, 1/picosecond, 0.002*picoseconds)

simulation = Simulation(pdb.topology, system, integrator)
simulation.context.setPositions(pdb.positions)


simulation.minimizeEnergy()
simulation.reporters.append(PDBReporter(pdb_reporter_file, record_interval))
simulation.reporters.append(StateDataReporter(state_data_reporter_file, record_interval, step=True, potentialEnergy=True, temperature=True))
simulation.step(total_number_of_steps)

print('Done!')
