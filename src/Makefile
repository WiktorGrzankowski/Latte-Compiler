all: latc_x86_64 latc

latc_x86_64:
	ghc --make -outputdir build/latc_x86_64 -o ../latc_x86_64 Main.hs

latc:
	ghc --make -outputdir build/latc -o ../latc Main.hs

clean:
	rm -rf build ../latc_x86_64 ../latc

# Phony targets
.PHONY: all latc_x86_64 latc clean
