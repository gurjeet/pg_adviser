
MODULE_big = index_adviser
OBJS	= index_adviser.o

DOCS = README.index_adviser

ifdef USE_PGXS
PGXS := $(shell pg_config --pgxs)
include $(PGXS)
else
subdir = contrib/pgadviser/index_advisor
top_builddir = ../../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
