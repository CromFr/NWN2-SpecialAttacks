
#include "specatk_inc"

void main(
	int nEvent,
	object oTarget,
	object oAtkArea, float fAtkX, float fAtkY, float fAtkZ, float fAtkFacing,
	float fDelay, int nShape, float fRange, float fWidth
	){

	object oCaster = OBJECT_SELF;
	struct SpecAtkProperties atk;
	atk.script = "";
	atk.loc    = Location(oAtkArea, Vector(fAtkX, fAtkY, fAtkZ), fAtkFacing);
	atk.delay  = fDelay;
	atk.shape  = nShape;
	atk.range  = fRange;
	atk.width  = fWidth;

	switch(nEvent){
		case SPECATK_EVENT_PREPARE:
			{
				SetScale(oTarget, GetScale(oTarget, SCALE_X) / 6.0, GetScale(oTarget, SCALE_Y) / 6.0, GetScale(oTarget, SCALE_Z) / 6.0);
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_fire_cone"), oTarget, atk.delay + 1.0);
			}
			break;

		case SPECATK_EVENT_IMPACT:
			{

			}
			break;

		case SPECATK_EVENT_HIT:
			{
				if(oTarget != OBJECT_SELF){
					ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_fire_ray", oTarget), OBJECT_SELF, 1.0);
					ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(5), DAMAGE_TYPE_FIRE), oTarget);
				}
			}
			break;
	}
}