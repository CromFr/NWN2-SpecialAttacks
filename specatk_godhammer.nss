
#include "specatk_inc"

void main(
	int nEvent, // Event ID
	object oTarget, // Target of the effect
	object oAtkArea, float fAtkX, float fAtkY, float fAtkZ, float fAtkFacing, // Do not use directly
	float fDelay, int nShape, float fRange, float fWidth // Do not use directly
	){

	object oCaster = OBJECT_SELF;
	specialAttack.script = "";
	specialAttack.loc    = Location(oAtkArea, Vector(fAtkX, fAtkY, fAtkZ), fAtkFacing);
	specialAttack.delay  = fDelay;
	specialAttack.shape  = nShape;
	specialAttack.range  = fRange;
	specialAttack.width  = fWidth;

	switch(nEvent){
		case SPECATK_EVENT_PREPARE_VISUAL:
			{
				// Called when the red mark appears. May be called multiple times to cover the shape area
				// oTarget: ipoint created for visual effects

				vector vTop = GetPositionFromLocation(specialAttack.loc);
				vTop.z += 15.0;

				object oIpoint = CreateTempIpoint(Location(GetArea(oTarget), vTop, 0.0), specialAttack.delay);
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray", oIpoint), oTarget, specialAttack.delay);
			}
			break;

		case SPECATK_EVENT_IMPACT_VISUAL:
			{
				// Called when the red mark disappears, just before creatures in shape are hit, for applying visual effects.
				// May be called multiple time on different ipoints depending on the shape
				// oTarget: ipoint created for visual effects
				ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectNWN2SpecialEffectFile("sp_holy_aoe"), specialAttack.loc);
			}
			break;

		case SPECATK_EVENT_IMPACT:
			{
				// Called when the red mark disappears, just before creatures in shape are hit
				// Can be used to apply custom effects/shapes
				// oTarget: OBJECT_INVALID
			}
			break;

		case SPECATK_EVENT_HIT:
			{
				// Called for each creature in the attack shape area
				// oTarget: creature hit
				ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(5), DAMAGE_TYPE_DIVINE), oTarget);
			}
			break;
	}
}