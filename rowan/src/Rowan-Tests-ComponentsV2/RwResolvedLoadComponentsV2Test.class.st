Class {
	#name : 'RwResolvedLoadComponentsV2Test',
	#superclass : 'RwAbstractLoadComponentV2Test',
	#category : 'Rowan-Tests-ComponentsV2'
}

{ #category : 'tests' }
RwResolvedLoadComponentsV2Test >> testBasic [
	"excercise basic functionality for RwResolvedLoadComponentV2"

	| projectName resolvedComponents allPackageNames stonString |
	projectName := 'ResolvedLoadComponentsV2Test'.
	resolvedComponents := RwResolvedLoadComponentsV2 new.
	resolvedComponents
		addSimpleComponentNamed: 'Core'
			condition: 'common'
			comment: 'Primary component used for loading the system.'.
	resolvedComponents
		addSimpleNestedComponentNamed: 'subs/Nested'
			condition: 'common'
			comment:
				'Nested component defines a shared subsystem of the primary project.';
		addSimpleNestedComponentNamed: 'Tests'
			condition: 'tests'
			comment: 'Contains all of the project tests.';
		addSimpleNestedComponentNamed: 'GemStone'
			condition: 'gemstone'
			comment:
				'Gemstone specific packages.';
		addSimpleNestedComponentNamed: 'GemStoneTests'
			condition: 'gemstone'
			comment:
				'Gemstone specific test packages.';
		yourself.

	resolvedComponents
		addProjectNamed: 'DependentProject'
			toComponentNamed: 'Core';
		addComponentNamed: 'Tests'
			toComponentNamed: 'Core';
		addComponentNamed: 'GemStone'
			toComponentNamed: 'Core';
		addComponentNamed: 'subs/Nested'
			toComponentNamed: 'Core';
		addComponentNamed: 'GemStoneTests'
			toComponentNamed: 'Tests';

		addPackagesNamed: {(projectName , '-Core')}
			toComponentNamed: 'Core';
		addPackageNamed: projectName , '-Tests'
			toComponentNamed: 'Tests';
		addPackageNamed: projectName , '-GemStone-Extensions'
			toComponentNamed: 'GemStone'
			gemstoneDefaultSymbolDictionaryForUser: 'SystemUser' -> 'Globals';
		addPackageNamed: projectName , '-GemStone-Tests'
			toComponentNamed: 'GemStoneTests';
		addPackagesNamed: {(projectName , '-Shared')}
			toComponentNamed: 'subs/Nested';

		gemstoneSetSymbolDictName: 'Globals' forPackageNamed: projectName , '-Shared';
		yourself.

	stonString := STON toStringPretty: resolvedComponents.	"useful to view full structure"
	allPackageNames := resolvedComponents _validate.
	self
		assert:
			allPackageNames asArray sort
				=
					#('ResolvedLoadComponentsV2Test-Tests' 'ResolvedLoadComponentsV2Test-GemStone-Tests' 'ResolvedLoadComponentsV2Test-Shared' 'ResolvedLoadComponentsV2Test-Core' 'ResolvedLoadComponentsV2Test-GemStone-Extensions')
						sort.
	self
		assert:
			(resolvedComponents
				gemstoneSymbolDictNameForPackageNamed: projectName , '-Shared'
				forUser: 'AUser'
				ifAbsent: [  ]) = 'Globals'.


	self
		_validateComponent: (resolvedComponents componentNamed: 'Core')
			condition: 'common'
			componentNames: {'Tests' .  'GemStone' . 'subs/Nested'}
			packageNames: {'ResolvedLoadComponentsV2Test-Core'}
			projectNames: {'DependentProject'};
		_validateComponent: (resolvedComponents componentNamed: 'Tests')
			condition: 'tests'
			componentNames: {'GemStoneTests'}
			packageNames: {'ResolvedLoadComponentsV2Test-Tests'}
			projectNames: {};
		_validateComponent: (resolvedComponents componentNamed: 'GemStone')
			condition: 'gemstone'
			componentNames: {}
			packageNames: {'ResolvedLoadComponentsV2Test-GemStone-Extensions'}
			projectNames: {};
		_validateComponent: (resolvedComponents componentNamed: 'GemStoneTests')
			condition: 'gemstone'
			componentNames: {}
			packageNames: {'ResolvedLoadComponentsV2Test-GemStone-Tests'}
			projectNames: {};
		yourself.

	self
		_validateComponent: (resolvedComponents componentNamed: 'subs/Nested')
			condition: 'common'
			componentNames: {}
			packageNames: {'ResolvedLoadComponentsV2Test-Shared'}
			projectNames: {};
		yourself.

	resolvedComponents removePackageNamed: 'ResolvedLoadComponentsV2Test-Shared'.
	stonString := STON toStringPretty: resolvedComponents.	"useful to view full structure"

	allPackageNames := resolvedComponents _validate.
	self
		assert:
			allPackageNames asArray sort
				=
					#('ResolvedLoadComponentsV2Test-Tests' 'ResolvedLoadComponentsV2Test-GemStone-Tests' 'ResolvedLoadComponentsV2Test-Core' 'ResolvedLoadComponentsV2Test-GemStone-Extensions')
						sort.

	self
		_validateComponent: (resolvedComponents componentNamed: 'subs/Nested')
			condition: 'common'
			componentNames: {}
			packageNames: {}
			projectNames: {};
		yourself.

	resolvedComponents removeComponentNamed: 'subs/Nested'.
	stonString := STON toStringPretty: resolvedComponents.	"useful to view full structure"

	allPackageNames := resolvedComponents _validate.
	self
		assert:
			allPackageNames asArray sort
				=
					#('ResolvedLoadComponentsV2Test-Tests' 'ResolvedLoadComponentsV2Test-GemStone-Tests' 'ResolvedLoadComponentsV2Test-Core' 'ResolvedLoadComponentsV2Test-GemStone-Extensions')
						sort.

	self
		_validateComponent: (resolvedComponents componentNamed: 'Core')
			condition: 'common'
			componentNames: { 'GemStone' . 'Tests'}
			packageNames: {'ResolvedLoadComponentsV2Test-Core'}
			projectNames: {'DependentProject'};
		yourself.
	self
		assert:
			(resolvedComponents componentNamed: 'subs/Nested' ifAbsent: [  ]) isNil.

	resolvedComponents removeProjectNamed: 'DependentProject'.
	stonString := STON toStringPretty: resolvedComponents.	"useful to view full structure"

	allPackageNames := resolvedComponents _validate.
	self
		assert:
			allPackageNames asArray sort
				=
					#('ResolvedLoadComponentsV2Test-Tests' 'ResolvedLoadComponentsV2Test-GemStone-Tests' 'ResolvedLoadComponentsV2Test-Core' 'ResolvedLoadComponentsV2Test-GemStone-Extensions')
						sort.

	self
		_validateComponent: (resolvedComponents componentNamed: 'Core')
			condition: 'common'
			componentNames: {  'GemStone' . 'Tests'}
			packageNames: {'ResolvedLoadComponentsV2Test-Core'}
			projectNames: {};
		yourself.
]
