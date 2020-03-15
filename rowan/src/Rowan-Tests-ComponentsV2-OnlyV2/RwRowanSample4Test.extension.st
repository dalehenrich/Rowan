Extension { #name : 'RwRowanSample4Test' }

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> testIssue208_adopt_load [

	"https://github.com/dalehenrich/Rowan/issues/208"

	"Using non-Rowan api, create the classes in the appropriate symbol dictionaries, adopt into Primer project, then load branch issue_208_0 ...
		the primer project should be empty"

		"Create classes in a couple of symbol dictionaries"
		"Create and load the primer project ... with two packages (one for each symbol dictionary) into which the classes will be adopted"
		"Adopt the classes into the primer project"
		"load the RowanSample4 project from disk - overly the correct project structure over the primer project classes"
		"validate that the primer project packages are empty"

	| primerProjectName specUrlString projectTools rowanProject gitTool gitRootPath projectName project repoRootPath symDictName1 
		symDictName2 symDict theClass instanceMethod classMethod symbolList projectDefinition primerPackageName1 primerPackageName2 
		loadedPrimerProject |

	projectTools := Rowan projectTools.
	primerProjectName := 'PrimerSample4'.
	symDictName1 := 'RowanSample4SymbolDict'.
	symDictName2 := 'RowanSample4DictionarySymbolDict'.
	primerPackageName1 := primerProjectName, '-', symDictName1.
	primerPackageName2 := primerProjectName, '-', symDictName2.
	projectName := 'RowanSample4'.
	symbolList := Rowan image symbolList.

	{ primerProjectName. projectName} 
		do: [:pn | 
			(Rowan image loadedProjectNamed: pn ifAbsent: [  ])
					ifNotNil: [ :prj | Rowan image _removeLoadedProject: prj ] ].

	"Create classes in a couple of symbol dictionaries"
	symDict := Rowan image newOrExistingSymbolDictionaryNamed: symDictName1.
	theClass := Object subclass: 'RowanSample4'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		inDictionary: symDict
		options: #().
	instanceMethod := theClass
		compileMethod: 'foo ^''foo'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.
	classMethod := theClass class
		compileMethod: 'bar ^''bar'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.

	symDict := Rowan image newOrExistingSymbolDictionaryNamed: symDictName2.
	theClass := IdentityKeyValueDictionary
		subclass: 'RowanSample4IdentityKeyValueDictionary'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		inDictionary: symDict
		options: #().
	instanceMethod := theClass
		compileMethod: 'foo ^''foo'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.

	"Create and load the primer project ... with two packages (one for each symbol dictionary) into which the classes will be adopted"
	projectDefinition := (Rowan globalNamed: 'RwProjectDefinition')
		newForGitBasedProjectNamed: primerProjectName.
	projectDefinition
		addPackageNamed: primerPackageName1;
		addPackageNamed: primerPackageName2;
		setSymbolDictName: symDictName1 forPackageNamed: primerPackageName1;
		setSymbolDictName: symDictName2 forPackageNamed: primerPackageName2;
		defaultSymbolDictName: self _symbolDictionaryName1.
	projectTools load loadProjectDefinition: projectDefinition.

	"Adopt the classes into the primer project"
	Rowan packageTools adopt
		adoptSymbolDictionaryNamed: symDictName1 intoPackageNamed: primerPackageName1;
		adoptSymbolDictionaryNamed: symDictName2 intoPackageNamed: primerPackageName2.

	"load the RowanSample4 project from disk - overly the correct project structure over the primer project classes"
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	specUrlString := self _rowanSample4_208_LoadSpecificationUrl.
	gitRootPath := self _testRowanProjectsSandbox.
	(gitRootPath / projectName) ensureDeleteAll.

	self _cloneProjectFromSpecUrl: specUrlString projectsHome: gitRootPath.

	project := Rowan projectNamed: projectName.
	repoRootPath := project repositoryRootPath asFileReference.

	gitTool := projectTools git.
	gitTool gitcheckoutIn: repoRootPath with: 'issue_208_0'.	

	projectTools load
		loadProjectNamed: projectName
		instanceMigrator: RwGsInstanceMigrator noMigration.

	"validate that the primer project packages are empty"
	loadedPrimerProject := Rowan image loadedProjectNamed: primerProjectName.
	loadedPrimerProject loadedPackages 
		do: [:loadedPackage |
			self assert: loadedPackage isEmpty ].

	self assert: loadedPrimerProject isDirty.
	self deny: (Rowan image loadedProjectNamed: projectName) isDirty
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> testIssue210 [

	"https://github.com/dalehenrich/Rowan/issues/210"

	"based on testIssue208_adopt_load"

	| primerProjectName specUrlString projectTools rowanProject gitTool gitRootPath projectName project repoRootPath symDictName1 
		symDictName2 symDict theClass instanceMethod classMethod symbolList projectDefinition primerPackageName1 primerPackageName2 |

	projectTools := Rowan projectTools.
	primerProjectName := 'PrimerSample4'.
	symDictName1 := 'RowanSample4SymbolDict'.
	symDictName2 := 'RowanSample4DictionarySymbolDict'.
	primerPackageName1 := primerProjectName, '-', symDictName1.
	primerPackageName2 := primerProjectName, '-', symDictName2.
	projectName := 'RowanSample4'.
	symbolList := Rowan image symbolList.

	{ primerProjectName. projectName} 
		do: [:pn | 
			(Rowan image loadedProjectNamed: pn ifAbsent: [  ])
					ifNotNil: [ :prj | Rowan image _removeLoadedProject: prj ] ].

	"Create classes in a couple of symbol dictionaries"
	symDict := Rowan image newOrExistingSymbolDictionaryNamed: symDictName1.
	theClass := Object subclass: 'RowanSample4'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		inDictionary: symDict
		options: #().
	instanceMethod := theClass
		compileMethod: 'foo ^''foo'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.
	classMethod := theClass class
		compileMethod: 'bar ^''bar'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.

	symDict := Rowan image newOrExistingSymbolDictionaryNamed: symDictName2.
	theClass := IdentityKeyValueDictionary
		subclass: 'RowanSample4IdentityKeyValueDictionary'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		inDictionary: symDict
		options: #().
	instanceMethod := theClass
		compileMethod: 'foo ^''foo'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.

	"Create and load the primer project ... with two packages into which the classes will be adopted"
	projectDefinition := (Rowan globalNamed: 'RwProjectDefinition')
		newForGitBasedProjectNamed: primerProjectName.
	projectDefinition
		addPackageNamed: primerPackageName1;
		addPackageNamed: primerPackageName2;
		setSymbolDictName: symDictName1 forPackageNamed: primerPackageName1;
		setSymbolDictName: symDictName2 forPackageNamed: primerPackageName2;
		defaultSymbolDictName: self _symbolDictionaryName1.
	projectTools load loadProjectDefinition: projectDefinition.

	"Adopt the classes into the primer project"
	Rowan packageTools adopt
		adoptSymbolDictionaryNamed: symDictName1 intoPackageNamed: primerPackageName1;
		adoptSymbolDictionaryNamed: symDictName2 intoPackageNamed: primerPackageName2.

	"now load the RowanSample4 project from disk"
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	specUrlString := self _rowanSample4_208_LoadSpecificationUrl.
	gitRootPath := self _testRowanProjectsSandbox.
	(gitRootPath / projectName) ensureDeleteAll.

	self _cloneProjectFromSpecUrl: specUrlString projectsHome: gitRootPath.

	project := Rowan projectNamed: projectName.
	repoRootPath := project repositoryRootPath asFileReference.

	gitTool := projectTools git.
	gitTool gitcheckoutIn: repoRootPath with: 'issue_208_0'.	

	projectTools load
		loadProjectNamed: projectName
		instanceMigrator: RwGsInstanceMigrator noMigration.
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> testIssue230 [

	"This test is also important for validating the fix to Issue #504:
		https://github.com/GemTalk/Rowan/issues/504#issuecomment-530599164
		At least confirm that it is NOT a good candidate, since this test is now failing
		with the new error introduced in the partial for for Issue #504"
	"https://github.com/dalehenrich/Rowan/issues/230"

	"new class version for class being loaded in after adopt --- initial RowanSample4 class created with instancesInvariant option, 
		so we get new version when class is loaded from disk"

	| primerProjectName specUrlString projectTools rowanProject gitTool gitRootPath projectName project repoRootPath symDictName1 
		symDictName2 symDict theClass instanceMethod classMethod symbolList projectDefinition primerPackageName1 primerPackageName2 |

	projectTools := Rowan projectTools.
	primerProjectName := 'PrimerSample4'.
	symDictName1 := 'RowanSample4SymbolDict'.
	symDictName2 := 'RowanSample4DictionarySymbolDict'.
	primerPackageName1 := primerProjectName, '-', symDictName1.
	primerPackageName2 := primerProjectName, '-', symDictName2.
	projectName := 'RowanSample4'.
	symbolList := Rowan image symbolList.

	{ primerProjectName. projectName} 
		do: [:pn | 
			(Rowan image loadedProjectNamed: pn ifAbsent: [  ])
					ifNotNil: [ :prj | Rowan image _removeLoadedProject: prj ] ].

	"Create classes in a couple of symbol dictionaries"
	symDict := Rowan image newOrExistingSymbolDictionaryNamed: symDictName1.
	theClass := Object subclass: 'RowanSample4'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		inDictionary: symDict
		options: #(instancesInvariant).
	instanceMethod := theClass
		compileMethod: 'foo ^''foo'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.
	classMethod := theClass class
		compileMethod: 'bar ^''bar'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.

	symDict := Rowan image newOrExistingSymbolDictionaryNamed: symDictName2.
	theClass := IdentityKeyValueDictionary
		subclass: 'RowanSample4IdentityKeyValueDictionary'
		instVarNames: #()
		classVars: #()
		classInstVars: #()
		poolDictionaries: #()
		inDictionary: symDict
		options: #().
	instanceMethod := theClass
		compileMethod: 'foo ^''foo'''
		dictionaries: symbolList
		category: 'accessing'
		environmentId: 0.

	"Create and load the primer project ... with two packages into which the classes will be adopted"
	projectDefinition := (Rowan globalNamed: 'RwProjectDefinition')
		newForGitBasedProjectNamed: primerProjectName.
	self assert: (projectDefinition projectDefinitionSourceProperty = RwLoadedProject _projectUnknownDefinitionSourceValue).
	projectDefinition
		addPackageNamed: primerPackageName1;
		addPackageNamed: primerPackageName2;
		setSymbolDictName: symDictName1 forPackageNamed: primerPackageName1;
		setSymbolDictName: symDictName2 forPackageNamed: primerPackageName2;
		defaultSymbolDictName: self _symbolDictionaryName1.
	projectTools load loadProjectDefinition: projectDefinition.

	"Adopt the classes into the primer project"
	Rowan packageTools adopt
		adoptSymbolDictionaryNamed: symDictName1 intoPackageNamed: primerPackageName1;
		adoptSymbolDictionaryNamed: symDictName2 intoPackageNamed: primerPackageName2.

	"now load the RowanSample4 project from disk"
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	specUrlString := self _rowanSample4_208_LoadSpecificationUrl.
	gitRootPath := self _testRowanProjectsSandbox.
	(gitRootPath / projectName) ensureDeleteAll.

	self _cloneProjectFromSpecUrl: specUrlString projectsHome: gitRootPath.

	project := Rowan projectNamed: projectName.
	repoRootPath := project repositoryRootPath asFileReference.

	gitTool := projectTools git.
	gitTool gitcheckoutIn: repoRootPath with: 'issue_208_0'.	

	projectTools load
		loadProjectNamed: projectName
		instanceMigrator: RwGsInstanceMigrator noMigration.
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> _cloneAndCreateProjectDefinitionFromSpecUrl: specUrlString projectRootPath: projectRootPath [

	| projectDefinition projectSetDefinition |
	projectDefinition := ((Rowan globalNamed: 'RwComponentProjectDefinition') newForUrl: specUrlString)
		projectHome: projectRootPath parent;
		clone;
		yourself.
	projectSetDefinition := Rowan projectTools read readProjectSetForComponentProjectDefinition: projectDefinition.
	^ projectSetDefinition projectNamed: projectDefinition name
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> _cloneProjectFromSpecUrl_300: specUrlString projectsHome: projectsHome registerProject: aBool [

	self _cloneProjectFromSpecUrl: specUrlString projectsHome: projectsHome registerProject: aBool
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> _createProjectDefinitionFromSpecUrl: specUrlString projectName: projectName [

	| rowanProject projectHome projectDefinition loadSpecUrl |
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	projectHome := self _testRowanProjectsSandbox.

	(projectHome / projectName) ensureDeleteAll.

	projectDefinition := (Rowan globalNamed: 'RwComponentProjectDefinition') newForUrl: specUrlString.
	projectDefinition projectHome: projectHome.
	projectDefinition cloneRepository.

	loadSpecUrl := 'file:', (projectHome / projectName / projectDefinition specsPath / 'RowanSample4_load_v2.ston') pathString.
	projectDefinition := (Rowan globalNamed: 'RwComponentProjectDefinition') newForUrl: loadSpecUrl.
	projectDefinition projectHome: projectHome.
	projectDefinition register.
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> _loadProjectFromSpecUrl: specUrlString repoRootPath: repoRootPath [

	| projectDefinition projectSetDefinition |
	projectDefinition := (Rowan globalNamed: 'RwComponentProjectDefinition') newForUrl: specUrlString.
	projectDefinition repositoryRoot: repoRootPath.
	projectSetDefinition := projectDefinition read.
	^ projectSetDefinition load
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> _projectDefinitionFromSpecUrl: specUrlString projectRootPath: projectRootPath [

	| projectDefinition |
	projectDefinition := (Rowan globalNamed: 'RwComponentProjectDefinition') newForUrl: specUrlString.
	projectDefinition repositoryRoot: projectRootPath.
	projectDefinition cloneRepository.
	^ projectDefinition read
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> _rowanSample4_208_LoadSpecificationUrl [

	| rowanProject |
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	^ 'file:' , rowanProject repositoryRootPath , '/test/specs/RowanSample4_208_load_v2.ston'
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> _rowanSample4_coreSpecificationUrl: repositoryRootPath [

	^ 'file:' , repositoryRootPath pathString, '/rowan/specs/RowanSample4_core_v2.ston'
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> _rowanSample4_loadSpecificationUrl: repositoryRootPath [

	^ 'file:' , repositoryRootPath pathString, '/rowan/specs/RowanSample4_load_v2.ston'
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> _rowanSample4LoadSpecificationUrl [

	| rowanProject |
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	^ 'file:' , rowanProject repositoryRootPath , '/test/specs/RowanSample4_load_v2.ston'
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> _rowanSample4LoadSpecificationUrl_295 [

	| rowanProject |
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	^ 'file:' , rowanProject repositoryRootPath , '/test/specs/RowanSample4_295_v2.ston'
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> _rowanSample4SpecificationUrl [

	| rowanProject |
	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	^ 'file:' , (rowanProject repositoryRootPath asFileReference / 'test/specs/RowanSample4_v2.ston') pathString
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> testIssue185_move_class_to_symbolDict_A_v20 [

	"https://github.com/dalehenrich/Rowan/issues/185"

	"issue_185_1 --> issue_185_3	:: move NewRowanSample4 class to RowanSample4SymbolDict symbol dictionary (no package rename)"

	| specUrlString projectTools rowanProject gitTool gitRootPath projectName project x repoRootPath 
		baselinePackageNames newClass ar audit |

	projectName := 'RowanSample4'.
	Rowan
		projectNamed: projectName 
		ifPresent: [:prj | Rowan image _removeLoadedProject: prj _loadedProject ].
	Rowan 
		projectNamed: projectName 
		ifPresent: [ :prj | self error: 'The project ', projectName printString, ' should not be loaded' ].

	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	specUrlString := self _rowanSample4LoadSpecificationUrl.
	projectTools := Rowan projectTools.

	gitRootPath := self _testRowanProjectsSandbox.

	(gitRootPath / projectName) ensureDeleteAll.

	self _cloneProjectFromSpecUrl: specUrlString projectsHome: gitRootPath.

	project := Rowan projectNamed: projectName.
	repoRootPath := project repositoryRootPath asFileReference.

	gitTool := projectTools git.
	gitTool gitcheckoutIn: repoRootPath with: 'issue_185_0'.				"starting point of test"

	project load.

	self assert: (audit := Rowan projectTools audit auditForProjectNamed: projectName) isEmpty.

	baselinePackageNames := #( 'RowanSample4-Core' 'RowanSample4-Extensions' 'RowanSample4-Tests' 'RowanSample4-GemStone' 
											'RowanSample4-GemStone-Tests').
	self
		assert:
			(x := project packageNames asArray sort) =  baselinePackageNames sort.

	self assert: (x := project loadedGroupNames asArray) = #('tests').
	self assert: (x := project loadedConfigurationNames asArray) = #('Load').

	gitTool gitcheckoutIn: repoRootPath with: 'issue_185_1'.				"New package added to the project"

	self assert: (Rowan globalNamed: 'NewRowanSample4') isNil.

	project load.

	self assert: (audit := Rowan projectTools audit auditForProjectNamed: projectName) isEmpty.

	self
		assert:
			(x := project packageNames asArray sort) =  (baselinePackageNames, #('RowanSample4-NewPackage')) sort.

	newClass := Rowan globalNamed: 'NewRowanSample4'.

	self assert: (newClass new perform: #foo) = 'foo'.

	ar := Rowan image symbolList dictionariesAndSymbolsOf: newClass.
	self assert: (ar first at: 1) name = #'RowanSample4DictionarySymbolDict'.

	gitTool gitcheckoutIn: repoRootPath with: 'issue_185_3'.				"Move NewRowanSample4 class to RowanSample4SymbolDict"

	project load.

	self assert: (audit := Rowan projectTools audit auditForProjectNamed: projectName) isEmpty.

	newClass := Rowan globalNamed: 'NewRowanSample4'.

	self assert: (newClass new perform: #foo) = 'foo'.

	ar := Rowan image symbolList dictionariesAndSymbolsOf: newClass.
	self assert: (x := (ar first at: 1) name) = #'RowanSample4SymbolDict'.

	self deny: ((Rowan globalNamed: 'RowanSample4DictionarySymbolDict') includesKey: #'NewRowanSample4')
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> testLoadComponentProjectFromUrl [

	| specUrlString projectTools projectName x project masterBranchSHA |

	projectName := 'RowanSample4'.
	(Rowan image loadedProjectNamed: projectName ifAbsent: [  ])
		ifNotNil: [ :prj | Rowan image _removeLoadedProject: prj ].

	specUrlString := self _rowanSample4LoadSpecificationUrl.
	projectTools := Rowan projectTools.

	projectTools load loadFromUrl: specUrlString.

	masterBranchSHA := 'ea371eb'.

	project := Rowan projectNamed: projectName.
	self assert: (x := project loadedConfigurationNames) asArray = #('Load').
	self assert: (x := project loadedGroupNames) asArray = #('tests').
	self deny: (x := project loadedCommitId) = masterBranchSHA.
]

{ #category : '*rowan-tests-componentsv2-onlyv2' }
RwRowanSample4Test >> testLoadProjectNamed_221A_v20 [

	"https://github.com/dalehenrich/Rowan/issues/221"

	"default configuration loading behavior differs between v1.2 and v2.0 ... this is the v1.2 variant"

	| specUrlString projectTools rowanProject gitTool gitRootPath projectName repoRootPath x 
		project audit |

	projectName := 'RowanSample4'.
	(Rowan image loadedProjectNamed: projectName ifAbsent: [  ])
		ifNotNil: [ :prj | Rowan image _removeLoadedProject: prj ].

	rowanProject := Rowan image _projectForNonTestProject: 'Rowan'.
	specUrlString := self _rowanSample4LoadSpecificationUrl.
	projectTools := Rowan projectTools.

	gitRootPath := self _testRowanProjectsSandbox.

	(gitRootPath / projectName) ensureDeleteAll.

	self _cloneProjectFromSpecUrl: specUrlString projectsHome: gitRootPath registerProject: true.

	repoRootPath := gitRootPath / projectName.

	gitTool := projectTools git.
	gitTool gitcheckoutIn: repoRootPath with: 'issue_302'.

"load core group"
	self 
		_loadProjectFromSpecUrl: (self _rowanSample4_coreSpecificationUrl: repoRootPath)
		repoRootPath: repoRootPath.

"validate"
	project := Rowan projectNamed: projectName.
	self assert: (audit := project audit) isEmpty.
	self assert: (Rowan globalNamed: 'RowanSample4') notNil.
	self assert: (Rowan globalNamed: 'RowanSample4Test') isNil.
	self assert: (x := project loadedConfigurationNames) asArray = #('Load').
	self assert: (x := project loadedGroupNames) asArray = #('core').

"load tests group"
	projectTools load
		loadProjectNamed: 'RowanSample4' withGroupNames: #('tests').

"validate"
	self assert: (audit := project audit) isEmpty.
	self assert: (Rowan globalNamed: 'RowanSample4') notNil.
	self assert: (Rowan globalNamed: 'RowanSample4Test') notNil.
	self assert: (x := project loadedConfigurationNames) asArray = #('Load').
	self assert: (x := project loadedGroupNames) asArray = #('tests').

"load core group -- unload the tests package"
	projectTools load
		loadProjectNamed: 'RowanSample4' withGroupNames: #('core').

"validate"
	self assert: (audit := project audit) isEmpty.
	self assert: (Rowan globalNamed: 'RowanSample4') notNil.
	self assert: (Rowan globalNamed: 'RowanSample4Test') isNil.
	self assert: (x := project loadedConfigurationNames) asArray = #('Load').
	self assert: (x := project loadedGroupNames) asArray = #('core').

"load Core configuration -- tests loaded"
	projectTools load
		loadProjectNamed: 'RowanSample4' withConfigurations: #( 'Core' ) groupNames: #().

"validate"
	self assert: (audit := project audit) isEmpty.
	self assert: (Rowan globalNamed: 'RowanSample4') notNil.
	self assert: (Rowan globalNamed: 'RowanSample4Test') notNil.
	self assert: (x := project loadedConfigurationNames) asArray = #( 'Core' ).
	self assert: (x := project loadedGroupNames) asArray = #( 'core' ).

"(re)load project"
	projectTools load
		loadProjectNamed: 'RowanSample4'.

"validate"
	self assert: (audit := project audit) isEmpty.
	self assert: (Rowan globalNamed: 'RowanSample4') notNil.
	self assert: (Rowan globalNamed: 'RowanSample4Test') notNil.
	self assert: (x := project  loadedConfigurationNames) asArray = #( 'Core' ).
	self assert: (x := project loadedGroupNames) asArray = #( 'core' ).

"load Load configuraiont and core group -- unload the tests package"
	projectTools load
		loadProjectNamed: 'RowanSample4' withConfigurations: #('Load') groupNames: #('core').

"validate"
	self assert: (audit := project audit) isEmpty.
	self assert: (Rowan globalNamed: 'RowanSample4') notNil.
	self assert: (Rowan globalNamed: 'RowanSample4Test') isNil.
	self assert: (x := project loadedConfigurationNames) asArray = #('Load').
	self assert: (x := project  loadedGroupNames) asArray = #('core').
]