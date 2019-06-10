Extension { #name : 'RwRowanSample4Test' }

{ #category : '*rowan-tests-35x' }
RwRowanSample4Test >> _cloneProjectFromSpecUrl: specUrlString projectsHome: projectsHome [

	(RwComponentProjectDefinition newForUrl: specUrlString)
		projectHome: projectsHome;
		clone;
		register.
]

{ #category : '*rowan-tests-35x' }
RwRowanSample4Test >> _createProjectDefinitionFromSpecUrl: specUrlString projectName: projectName [

	| rowanProject projectHome projectDefinition loadSpecUrl |
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	projectHome := rowanProject repositoryRootPath asFileReference / 'test/testRepositories/repos/'.

	(projectHome / projectName) ensureDeleteAll.

	projectDefinition := RwComponentProjectDefinition newForUrl: specUrlString.
	projectDefinition projectHome: projectHome.
	projectDefinition cloneRepository.

	loadSpecUrl := 'file:', (projectHome / projectName / projectDefinition specsPath / 'RowanSample4_load_v2.ston') pathString.
	projectDefinition := RwComponentProjectDefinition newForUrl: loadSpecUrl.
	projectDefinition projectHome: projectHome.
	projectDefinition register.
]

{ #category : '*rowan-tests-35x' }
RwRowanSample4Test >> _projectDefinitionFromSpecUrl: specUrlString projectRootPath: projectRootPath [

	| projectDefinition |
	projectDefinition := RwComponentProjectDefinition newForUrl: specUrlString.
	projectDefinition projectHome: projectRootPath parent.
	projectDefinition clone.
	^ projectDefinition
]

{ #category : '*rowan-tests-35x' }
RwRowanSample4Test >> _rowanSample4_208_LoadSpecificationUrl [

	| rowanProject |
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	^ 'file:' , rowanProject repositoryRootPath , '/test/specs/RowanSample4_208_load_v2.ston'
]

{ #category : '*rowan-tests-35x' }
RwRowanSample4Test >> _rowanSample4LoadSpecificationUrl [

	| rowanProject |
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	^ 'file:' , rowanProject repositoryRootPath , '/test/specs/RowanSample4_load_v2.ston'
]

{ #category : '*rowan-tests-35x' }
RwRowanSample4Test >> _rowanSample4LoadSpecificationUrl_295 [

	| rowanProject |
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	^ 'file:' , rowanProject repositoryRootPath , '/test/specs/RowanSample4_295_v2.ston'
]

{ #category : '*rowan-tests-35x' }
RwRowanSample4Test >> _rowanSample4SpecificationUrl [

	| rowanProject |
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	^ 'file:' , (rowanProject repositoryRootPath asFileReference / 'test/specs/RowanSample4_v2.ston') pathString
]