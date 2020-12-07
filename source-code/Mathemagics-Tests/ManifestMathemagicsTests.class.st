"
All tests for this library. I separated by a few quick tests that cover most basics, for when code is getting changed, a the rest of tests that are slower.

Notice there are two test that check that parser will continue to process if any opening or closing parenthesis are missing. On that case a warning notification is displayed. I left that like that rather than a flag or something messy. I expect to continue and not fail.

Contact:
	Gustavo Pistoia.
	See help class for more information.
"
Class {
	#name : #ManifestMathemagicsTests,
	#superclass : #PackageManifest,
	#category : #'Mathemagics-Tests-Manifest'
}
