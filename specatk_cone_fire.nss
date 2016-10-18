
#include "specatk_inc"

int StartingConditional(
	int nEvent,
	object oTarget,
	object oAtkArea, float fAtkX, float fAtkY, float fAtkZ, float fAtkFacing,
	float fDelay, int nShape, float fRange, float fWidth, object oVarContainer
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
				//Effect scale is too big for cone vfx
				SetScale(oTarget, GetScale(oTarget, SCALE_X) / 6.0, GetScale(oTarget, SCALE_Y) / 6.0, GetScale(oTarget, SCALE_Z) / 6.0);

				DelayCommand(atk.delay-0.5, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_fire_cone"), oTarget, 6.0));

				SetLocalInt(atk.var_container, "remaining_impacts", 6);
			}
			break;

		case SPECATK_EVENT_IMPACT:
			{
				int nRemainingImpacts = GetLocalInt(atk.var_container, "remaining_impacts") - 1;
				SetLocalInt(atk.var_container, "remaining_impacts", nRemainingImpacts);
				if(nRemainingImpacts >= 0)
					return 1000;
			}
			return 0;

		case SPECATK_EVENT_HIT:
			{
				if(oTarget != OBJECT_SELF){
					ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_fire_ray", oTarget), OBJECT_SELF, 1.0);
					ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(5), DAMAGE_TYPE_FIRE), oTarget);
				}
			}
			break;
	}
	return 0;
}