# Build the main readme from two parts
# Kudos to jfg956 and Kusalananda for the sed concat tip
# https://unix.stackexchange.com/questions/32908/how-to-insert-the-content-of-a-file-into-another-file-before-a-pattern-marker
README.md : README_MAIN.md MARTe2_References.md
	sed '/## MARTe2 References/e cat MARTe2_References.md' README_MAIN.md > README.md
