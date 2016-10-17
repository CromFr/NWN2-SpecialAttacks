
#include "specatk_inc"

void main(
	int nEvent,
	object oTarget,
	object oAtkArea, float fAtkX, float fAtkY, float fAtkZ, float fAtkFacing,
	float fDelay, int nShape, float fRange, float fWidth
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
				vector vStart = GetPositionFromLocation(specialAttack.loc);
				vStart.z += 1.0;
				vector vEnd = GetPosition(oTarget);
				vEnd.z += 1.0;

				object oIpointStart = CreateTempIpoint(Location(GetArea(oTarget), vStart, 0.0), specialAttack.delay);
				object oIpointEnd = CreateTempIpoint(Location(GetArea(oTarget), vEnd, 0.0), specialAttack.delay);

				DelayCommand(specialAttack.delay-0.5, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_lightning_ray", oIpointStart), oIpointEnd, 0.5));
			}
			break;

		case SPECATK_EVENT_IMPACT_VISUAL:
			{

			}
			break;

		case SPECATK_EVENT_IMPACT:
			{

			}
			break;

		case SPECATK_EVENT_HIT:
			{
				if(oTarget != OBJECT_SELF){
					ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectNWN2SpecialEffectFile("sp_lightning_hit"), oTarget);
					ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(5), DAMAGE_TYPE_ELECTRICAL), oTarget);
				}
			}
			break;
	}
}