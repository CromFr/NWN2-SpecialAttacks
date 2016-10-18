
#include "specatk_inc"

//
// nEvent: Event type SPECATK_EVENT_*
// oTarget: Depends on the event
//  - SPECATK_EVENT_PREPARE: ipoint for applying effects, scaled apropriately
//  - SPECATK_EVENT_IMPACT: OBJECT_INVALID
//  - SPECATK_EVENT_HIT: Creature in the shape
// Other args are for special attack information
//
// Return: For SPECATK_EVENT_IMPACT event, it is the delay in milliseconds before next impact
int StartingConditional(
	int nEvent,
	object oTarget,
	object oAtkArea, float fAtkX, float fAtkY, float fAtkZ, float fAtkFacing, // Do not use directly
	float fDelay, int nShape, float fRange, float fWidth, object oVarContainer // Do not use directly
	){
	object oCaster = OBJECT_SELF;
	atk.script = "";
	atk.loc    = Location(oAtkArea, Vector(fAtkX, fAtkY, fAtkZ), fAtkFacing);
	atk.delay  = fDelay;
	atk.shape  = nShape;
	atk.range  = fRange;
	atk.width  = fWidth;
	atk.var_container = oVarContainer;

	switch(nEvent){
		case SPECATK_EVENT_PREPARE:
			{
				// Called when the red mark appears
				vector vTop = GetPositionFromLocation(atk.loc);
				vTop.z += 15.0;

				object oIpoint = CreateTempIpoint(Location(GetArea(oTarget), vTop, 0.0));
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray", oIpoint), oTarget, atk.delay);
			}
			break;

		case SPECATK_EVENT_IMPACT:
			{
				// Called when the red mark disappears, just before creatures in shape are hit, for applying visual effects.
				ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectNWN2SpecialEffectFile("sp_holy_aoe"), atk.loc);
			}
			return 0;

		case SPECATK_EVENT_HIT:
			{
				// Called for each creature in the attack shape area
				ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(5), DAMAGE_TYPE_DIVINE), oTarget);
			}
			break;
	}
	return 0;
}