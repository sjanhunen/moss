# This valid module is used for unit testing import

$.variable1 = v1
$.variable2 = v2

define $.struct
$.member1 = 4
$.member2 = 8
endef

$(eval $(call $.struct,$.defn))
