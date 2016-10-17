
#include "specatk_inc"

void main()
{
	object oPC = GetItemActivator();
	object oItem = GetItemActivated();
	location lTarget = GetItemActivatedTargetLocation();


	//AssignCommand(oPC, CastSpecialAttack(GetTag(oItem), lTarget, 2.0, SPECATK_SHAPE_CIRCLE, Random(10)*1.0+1.0));


	int nShape = SPECATK_SHAPE_CIRCLE;
	if(FindSubString(GetTag(oItem), "_line_") >= 0)
		nShape = SPECATK_SHAPE_LINE;
	else if(FindSubString(GetTag(oItem), "_cone_") >= 0)
		nShape = SPECATK_SHAPE_CONE;

	float fRange, fWidth;
	location lLoc;
	switch(nShape){
		case SPECATK_SHAPE_CIRCLE:
			fRange = Random(5)+2.0;
			fWidth = 0.0;
			lLoc = lTarget;
			break;
		case SPECATK_SHAPE_LINE:
			fRange = Random(20)+5.0;
			fWidth = Random(4)+1.0;
			lLoc = GetLocation(oPC);
			break;
		case SPECATK_SHAPE_CONE:
			fRange = Random(20)+5.0;
			fWidth = Random(160)+5.0;
			lLoc = GetLocation(oPC);
			break;
	}



	AssignCommand(oPC, CastSpecialAttack(GetTag(oItem), lLoc, 2.0, nShape, fRange, fWidth));

}