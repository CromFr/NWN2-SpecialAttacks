

const int SPECATK_EVENT_PREPARE_VISUAL = 1;
const int SPECATK_EVENT_IMPACT_VISUAL = 2;
const int SPECATK_EVENT_IMPACT = 3;
const int SPECATK_EVENT_HIT = 4;

const int SPECATK_SHAPE_NONE = 0;
const int SPECATK_SHAPE_CIRCLE = 1;
const int SPECATK_SHAPE_LINE = 2;
const int SPECATK_SHAPE_CONE = 3;


struct SpecAtkProperties{
	string script;
	location loc;
	float delay;
	int shape;
	float range;
	float width;
};

struct SpecAtkProperties specialAttack;

// Creates an ipoint for applying effects, that will be destroyed after fDuration seconds
object CreateTempIpoint(location lLocation, float fDuration){
	object oIpoint = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_ipoint ", lLocation);
	AssignCommand(oIpoint, DelayCommand(fDuration, DestroyObject(oIpoint)));
	return oIpoint;
}

void _CallScript(int nEvent, object oTarget){
	SendMessageToPC(GetFirstPC(), "_CallScript: "+specialAttack.script+" event="+IntToString(nEvent));

	ClearScriptParams();
	AddScriptParameterInt(nEvent);
	AddScriptParameterObject(oTarget);

	AddScriptParameterObject(GetAreaFromLocation(specialAttack.loc));
	AddScriptParameterFloat(GetPositionFromLocation(specialAttack.loc).x);
	AddScriptParameterFloat(GetPositionFromLocation(specialAttack.loc).y);
	AddScriptParameterFloat(GetPositionFromLocation(specialAttack.loc).z);
	AddScriptParameterFloat(GetFacingFromLocation(specialAttack.loc));
	AddScriptParameterFloat(specialAttack.delay);
	AddScriptParameterInt(specialAttack.shape);
	AddScriptParameterFloat(specialAttack.range);
	AddScriptParameterFloat(specialAttack.width);

	ExecuteScriptEnhanced(specialAttack.script, OBJECT_SELF);
}


void _Prepare(){

	switch(specialAttack.shape){
		case SPECATK_SHAPE_NONE:
			{
				//Ipoint & script
				object oIpoint = CreateTempIpoint(specialAttack.loc, specialAttack.delay+6.0);
				SetScale(oIpoint, specialAttack.range, specialAttack.range, specialAttack.range);

				_CallScript(SPECATK_EVENT_PREPARE_VISUAL, oIpoint);
				DelayCommand(specialAttack.delay, _CallScript(SPECATK_EVENT_IMPACT_VISUAL, oIpoint));
			}
			break;
		case SPECATK_SHAPE_CIRCLE:
			{
				//Ipoint & script
				object oIpoint = CreateTempIpoint(specialAttack.loc, specialAttack.delay+6.0);
				SetScale(oIpoint, specialAttack.range, specialAttack.range, specialAttack.range);

				_CallScript(SPECATK_EVENT_PREPARE_VISUAL, oIpoint);
				DelayCommand(specialAttack.delay, _CallScript(SPECATK_EVENT_IMPACT_VISUAL, oIpoint));

				//Red mark
				vector vCircle = GetPositionFromLocation(specialAttack.loc);
				vCircle.z = specialAttack.range*10.0-100.0;// height = range*10 - VFXLength/2
				location lCircle = Location(GetAreaFromLocation(specialAttack.loc), vCircle, 0.0);
				ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("specatk_shape_circle"), lCircle, specialAttack.delay);

				//Visualize limits
				// vector vTest = GetPositionFromLocation(specialAttack.loc);
				// vTest.x += specialAttack.range;
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(GetAreaFromLocation(specialAttack.loc), vTest, 0.0), specialAttack.delay);
				// vTest.x -= 2.0*specialAttack.range;
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(GetAreaFromLocation(specialAttack.loc), vTest, 0.0), specialAttack.delay);
				// vTest.x += specialAttack.range;
				// vTest.y += specialAttack.range;
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(GetAreaFromLocation(specialAttack.loc), vTest, 0.0), specialAttack.delay);
				// vTest.y -= 2.0*specialAttack.range;
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(GetAreaFromLocation(specialAttack.loc), vTest, 0.0), specialAttack.delay);

			}
			break;
		case SPECATK_SHAPE_LINE:
			{
				object oArea = GetAreaFromLocation(specialAttack.loc);
				vector vStart = GetPositionFromLocation(specialAttack.loc);
				float fFacing = GetFacingFromLocation(specialAttack.loc);

				vector vDirection = AngleToVector(fFacing);
				vector vPerpendicular = AngleToVector(fFacing + 90.0);
				vector vPosCenter = vStart + vDirection * specialAttack.range / 2.0;

				float fMarkScaleWidth = specialAttack.width / 4.0;
				float fMarkScaleLength = specialAttack.range / 10.0;

				vector vLeft = vPosCenter + vPerpendicular * (specialAttack.width / 2.0);
				object oIpointLeft = CreateTempIpoint(Location(oArea, vLeft, fFacing), specialAttack.delay + 6.0);
				SetScale(oIpointLeft, fMarkScaleWidth, fMarkScaleLength, 1.0);
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("specatk_shape_line"), oIpointLeft, specialAttack.delay);

				vector vRight = vPosCenter + vPerpendicular * (-specialAttack.width / 2.0);
				object oIpointRight = CreateTempIpoint(Location(oArea, vRight, fFacing + 180.0), specialAttack.delay + 6.0);
				SetScale(oIpointRight, fMarkScaleWidth, fMarkScaleLength, 1.0);
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("specatk_shape_line"), oIpointRight, specialAttack.delay);

				vector vEnd = vStart + vDirection * specialAttack.range;
				object oIpointEnd = CreateTempIpoint(Location(oArea, vEnd, fFacing), specialAttack.delay + 6.0);
				SetScale(oIpointEnd, fMarkScaleWidth, 1.0, 1.0);
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("specatk_shape_line_end"), oIpointEnd, specialAttack.delay);

				object oIpointStart = CreateTempIpoint(Location(oArea, vStart, fFacing), specialAttack.delay + 6.0);
				SetScale(oIpointStart, fMarkScaleWidth, 1.0, 1.0);
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("specatk_shape_line_start"), oIpointStart, specialAttack.delay);

				//Ipoint & script
				_CallScript(SPECATK_EVENT_PREPARE_VISUAL, oIpointEnd);
				DelayCommand(specialAttack.delay, _CallScript(SPECATK_EVENT_IMPACT_VISUAL, oIpointEnd));

				//Visualize limits
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(oArea, vStart+vDirection*specialAttack.range, 0.0), specialAttack.delay);
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(oArea, vLeft, 0.0), specialAttack.delay);
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(oArea, vRight, 0.0), specialAttack.delay);
			}
			break;

		case SPECATK_SHAPE_CONE:
			{
				object oArea = GetAreaFromLocation(specialAttack.loc);
				vector vO = GetPositionFromLocation(specialAttack.loc);
				float fFacing = GetFacingFromLocation(specialAttack.loc);
				float fOffsetCone = 0.0;
				if(specialAttack.width < 60.0){
					fOffsetCone = 1.0 / cos(specialAttack.width);

					object oIpointStart = CreateTempIpoint(specialAttack.loc, specialAttack.delay + 6.0);
					SetScale(oIpointStart, 2.0 * tan(specialAttack.width), 2.0, 1.0);
					ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("specatk_shape_line_end"), oIpointStart, specialAttack.delay);
				}
				else{
					float fAngleToFill = (specialAttack.width - 15.0) * 2.0;
					int nFillConeCount = FloatToInt(fAngleToFill / 45.0) + 1;
					float fDelta = fAngleToFill / (nFillConeCount*1.0);

					SendMessageToPC(OBJECT_SELF, "fFacing="+FloatToString(fFacing)+" fAngleToFill="+FloatToString(fAngleToFill)+" nFillConeCount="+IntToString(nFillConeCount)+" fDelta="+FloatToString(fDelta));

					int i;
					for(i = 0 ; i < nFillConeCount ; i++){
						float fIpointFacing = fFacing - specialAttack.width + 15.0 + (i + 0.5) * fDelta;
						SendMessageToPC(OBJECT_SELF, "==> fIpointFacing="+FloatToString(fIpointFacing));

						object oIpoint = CreateTempIpoint(Location(oArea, vO, fIpointFacing), specialAttack.delay + 6.0);
						SetScale(oIpoint, 2.0, specialAttack.range / 10.0, 1.0);
						ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("specatk_shape_cone_fill"), oIpoint, specialAttack.delay);
					}


				}

				float fFacingLeft = fFacing + specialAttack.width;
				vector vDirectionLeft = AngleToVector(fFacingLeft);
				vector vIpointLeft = vO + vDirectionLeft * (fOffsetCone + (specialAttack.range - fOffsetCone) / 2.0);
				object oIpointLeft = CreateTempIpoint(Location(oArea, vIpointLeft, fFacingLeft), specialAttack.delay + 6.0);
				SetScale(oIpointLeft, 2.0, (specialAttack.range - fOffsetCone) / 10.0, 1.0);
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("specatk_shape_line"), oIpointLeft, specialAttack.delay);

				float fFacingRight = fFacing - specialAttack.width;
				vector vDirectionRight = AngleToVector(fFacingRight);
				vector vIpointRight = vO + vDirectionRight * (fOffsetCone + (specialAttack.range - fOffsetCone) / 2.0);
				object oIpointRight = CreateTempIpoint(Location(oArea, vIpointRight, fFacingRight+180.0), specialAttack.delay + 6.0);
				SetScale(oIpointRight, 2.0, (specialAttack.range - fOffsetCone) / 10.0, 1.0);
				ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("specatk_shape_line"), oIpointRight, specialAttack.delay);


				//Ipoint & script
				object oIpoint = CreateTempIpoint(specialAttack.loc, specialAttack.delay + 6.0);
				SetScale(oIpoint, specialAttack.range, specialAttack.range, specialAttack.range);

				_CallScript(SPECATK_EVENT_PREPARE_VISUAL, oIpoint);
				DelayCommand(specialAttack.delay, _CallScript(SPECATK_EVENT_IMPACT_VISUAL, oIpoint));
			}
			break;

		default:
			SendMessageToPC(OBJECT_SELF, "BUG: Shape "+IntToString(specialAttack.shape)+" not implemented in _Prepare()");
	}
}

float _GetSideFromLine(vector vA, vector vB, vector vPoint){
	float fA = - (vB.y - vA.y);
	float fB = vB.x - vA.x;
	float fC = - (fA * vA.x + fB * vA.y);
	return fA * vPoint.x + fB * vPoint.y + fC;
}

void _Impact(){
	_CallScript(SPECATK_EVENT_IMPACT, OBJECT_INVALID);

	switch(specialAttack.shape){
		case SPECATK_SHAPE_NONE:
			break;
		case SPECATK_SHAPE_CIRCLE:
			{
				object oNear = GetFirstObjectInShape(SHAPE_SPHERE, specialAttack.range, specialAttack.loc);
				while(GetIsObjectValid(oNear)){

					_CallScript(SPECATK_EVENT_HIT, oNear);

					oNear = GetNextObjectInShape(SHAPE_SPHERE, specialAttack.range, specialAttack.loc);
				}
			}
			break;

		case SPECATK_SHAPE_LINE:
			{
				// A--------------------B/
				// O                    <=
				// C--------------------D\
				vector vO = GetPositionFromLocation(specialAttack.loc);
				float fFacing = GetFacingFromLocation(specialAttack.loc);
				vector vDirection = AngleToVector(fFacing);
				vector vPerpendicular = AngleToVector(fFacing + 90.0);

				vector vA = vO - vPerpendicular * (specialAttack.width / 2.0);
				vector vB = vA + vDirection * specialAttack.range;
				vector vC = vO + vPerpendicular * (specialAttack.width / 2.0);
				vector vD = vC + vDirection * specialAttack.range;

				object oNear = GetFirstObjectInShape(SHAPE_SPHERE, specialAttack.range, specialAttack.loc);
				while(GetIsObjectValid(oNear)){

					vector vNear = GetPosition(oNear);
					if(_GetSideFromLine(vA, vB, vNear) >= 0.0
					&& _GetSideFromLine(vC, vD, vNear) <= 0.0
					&& _GetSideFromLine(vA, vC, vNear) <= 0.0){
						_CallScript(SPECATK_EVENT_HIT, oNear);
					}

					oNear = GetNextObjectInShape(SHAPE_SPHERE, specialAttack.range, specialAttack.loc);
				}
			}
			break;

		case SPECATK_SHAPE_CONE:
			{
				//   __-- A
				// O __
				//     -- B
				vector vO = GetPositionFromLocation(specialAttack.loc);
				float fFacing = GetFacingFromLocation(specialAttack.loc);
				vector vA = vO + AngleToVector(fFacing - specialAttack.width) * specialAttack.range;
				vector vB = vO + AngleToVector(fFacing + specialAttack.width) * specialAttack.range;

				object oNear = GetFirstObjectInShape(SHAPE_SPHERE, specialAttack.range, specialAttack.loc);
				while(GetIsObjectValid(oNear)){

					vector vNear = GetPosition(oNear);
					if((specialAttack.width <= 90.0
					&& _GetSideFromLine(vO, vA, vNear) >= 0.0 && _GetSideFromLine(vO, vB, vNear) <= 0.0)
					|| (specialAttack.width > 90.0
					&& (_GetSideFromLine(vO, vA, vNear) >= 0.0 || _GetSideFromLine(vO, vB, vNear) <= 0.0))){

						_CallScript(SPECATK_EVENT_HIT, oNear);
					}

					oNear = GetNextObjectInShape(SHAPE_SPHERE, specialAttack.range, specialAttack.loc);
				}
			}
			break;

		default:
			SendMessageToPC(OBJECT_SELF, "BUG: Shape "+IntToString(specialAttack.shape)+" not implemented in _Impact()");
	}
}

// Cast a special attack, with a red mark on the floor to warn players
//
// sAtkScript: Callback script to handle events
// lLoc: Attack target location
// fDelay: Duration of the red mark before hitting creatures inside
// nShape: SPECATK_SHAPE_*
// fRange: Range of the shape (circle/cone radius, line length, ...)
// fWidth: Depends on nShape
//  - SPECATK_SHAPE_NONE: may be used by sAtkScript
//  - SPECATK_SHAPE_CIRCLE: ignored
//  - SPECATK_SHAPE_LINE: thickness of the line
//  - SPECATK_SHAPE_CONE: half angle in degrees
//
// Notes:
//   SPECATK_SHAPE_LINE and SPECATK_SHAPE_CONE won't be displayed very well on sloped terrain. SPECATK_SHAPE_CIRCLE is OK
void CastSpecialAttack(string sAtkScript, location lLoc, float fDelay, int nShape, float fRange, float fWidth = 0.0){
	specialAttack.script = sAtkScript;
	specialAttack.loc = lLoc;
	specialAttack.delay = fDelay;
	specialAttack.shape = nShape;
	specialAttack.range = fRange;
	specialAttack.width = fWidth;

	_Prepare();
	DelayCommand(fDelay, _Impact());
}

