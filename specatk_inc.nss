

const int SPECATK_EVENT_PREPARE = 1;
const int SPECATK_EVENT_IMPACT = 2;
const int SPECATK_EVENT_HIT = 3;

const int SPECATK_SHAPE_NONE = 0;
const int SPECATK_SHAPE_CIRCLE = 1;
const int SPECATK_SHAPE_LINE = 2;
const int SPECATK_SHAPE_CONE = 3;

// CastSpecialAttack parameters.
// Practical for attack scripts
struct SpecAtkProperties{
	string script;
	location loc;
	float delay;
	int shape;
	float range;
	float width;
	// You can use this ipoint to set custom local variables. It will be destroyed 6 seconds after the end of effects
	object var_container;
};



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
// fDuration: duration of the mark after the impact
//
// Notes:
//   SPECATK_SHAPE_LINE and SPECATK_SHAPE_CONE won't be displayed very well on sloped terrain. SPECATK_SHAPE_CIRCLE is OK
void CastSpecialAttack(string sAtkScript, location lLoc, float fDelay, int nShape, float fRange, float fWidth = 0.0);

// Check if lPoint is in the shape created at location lShape
//
// nShape: SPECATK_SHAPE_*
int GetIsInShape(location lPoint, location lShape, int nShape, float fRange, float fWidth);

// Creates an ipoint for applying effects, that will be destroyed when the special attack ends
// Warning: atk needs to be set
object CreateTempIpoint(struct SpecAtkProperties atk, location lLocation);











// ============================================================================
// Implementation
// ============================================================================

void _Impact(struct SpecAtkProperties atk, object oTarget);


int _CallScriptInt(struct SpecAtkProperties atk, int nEvent, object oTarget){
	ClearScriptParams();
	AddScriptParameterInt(nEvent);
	AddScriptParameterObject(oTarget);

	AddScriptParameterObject(GetAreaFromLocation(atk.loc));
	AddScriptParameterFloat(GetPositionFromLocation(atk.loc).x);
	AddScriptParameterFloat(GetPositionFromLocation(atk.loc).y);
	AddScriptParameterFloat(GetPositionFromLocation(atk.loc).z);
	AddScriptParameterFloat(GetFacingFromLocation(atk.loc));
	AddScriptParameterFloat(atk.delay);
	AddScriptParameterInt(atk.shape);
	AddScriptParameterFloat(atk.range);
	AddScriptParameterFloat(atk.width);
	AddScriptParameterObject(atk.var_container);

	return ExecuteScriptEnhanced(atk.script, OBJECT_SELF);
}

void _CallScript(struct SpecAtkProperties atk, int nEvent, object oTarget){
	_CallScriptInt(atk, nEvent, oTarget);
}

void _RegisterObjectToDestroy(struct SpecAtkProperties atk, object o){
	int nIndex = GetLocalInt(atk.var_container, "_destroy_cnt");
	SetLocalObject(atk.var_container, "_destroy_"+IntToString(nIndex), o);
	SetLocalInt(atk.var_container, "_destroy_cnt", nIndex+1);
}
void _DestroyRegisteredObjects(struct SpecAtkProperties atk){
	int nCount = GetLocalInt(atk.var_container, "_destroy_cnt");
	int i;
	for(i = 0 ; i < nCount ; i++){
		object oIpoint = GetLocalObject(atk.var_container, "_destroy_"+IntToString(i));
		effect e = GetFirstEffect(oIpoint);
		while(GetIsEffectValid(e)){
			RemoveEffect(oIpoint, e);
			e = GetNextEffect(oIpoint);
		}
		DelayCommand(1.0, DestroyObject(oIpoint));
	}
}

void _Prepare(struct SpecAtkProperties atk){

	switch(atk.shape){
		case SPECATK_SHAPE_NONE:
			{
				//Ipoint & script
				object oIpoint = CreateTempIpoint(atk, atk.loc);
				SetScale(oIpoint, atk.range, atk.range, atk.range);

				_CallScript(atk, SPECATK_EVENT_PREPARE, oIpoint);
				DelayCommand(atk.delay, _Impact(atk, oIpoint));
			}
			break;
		case SPECATK_SHAPE_CIRCLE:
			{
				//Ipoint & script
				object oIpoint = CreateTempIpoint(atk, atk.loc);
				SetScale(oIpoint, atk.range, atk.range, atk.range);

				_CallScript(atk, SPECATK_EVENT_PREPARE, oIpoint);
				DelayCommand(atk.delay, _Impact(atk, oIpoint));

				//Red mark
				vector vCircle = GetPositionFromLocation(atk.loc);
				vCircle.z += atk.range*10.0-100.0;// height = range*10 - VFXLength/2
				object oCircle = CreateTempIpoint(atk, Location(GetAreaFromLocation(atk.loc), vCircle, 0.0));

				ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectNWN2SpecialEffectFile("specatk_shape_circle"), oCircle);

				//Visualize limits
				// vector vTest = GetPositionFromLocation(atk.loc);
				// vTest.x += atk.range;
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(GetAreaFromLocation(atk.loc), vTest, 0.0), atk.delay);
				// vTest.x -= 2.0*atk.range;
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(GetAreaFromLocation(atk.loc), vTest, 0.0), atk.delay);
				// vTest.x += atk.range;
				// vTest.y += atk.range;
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(GetAreaFromLocation(atk.loc), vTest, 0.0), atk.delay);
				// vTest.y -= 2.0*atk.range;
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(GetAreaFromLocation(atk.loc), vTest, 0.0), atk.delay);
			}
			break;
		case SPECATK_SHAPE_LINE:
			{
				object oArea = GetAreaFromLocation(atk.loc);
				vector vStart = GetPositionFromLocation(atk.loc);
				float fFacing = GetFacingFromLocation(atk.loc);

				vector vDirection = AngleToVector(fFacing);
				vector vPerpendicular = AngleToVector(fFacing + 90.0);
				vector vPosCenter = vStart + vDirection * atk.range / 2.0;

				float fMarkScaleWidth = atk.width / 4.0;
				float fMarkScaleLength = atk.range / 10.0;

				vector vLeft = vPosCenter + vPerpendicular * (atk.width / 2.0);
				object oIpointLeft = CreateTempIpoint(atk, Location(oArea, vLeft, fFacing));
				SetScale(oIpointLeft, fMarkScaleWidth, fMarkScaleLength, 1.0);
				ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectNWN2SpecialEffectFile("specatk_shape_line"), oIpointLeft);

				vector vRight = vPosCenter + vPerpendicular * (-atk.width / 2.0);
				object oIpointRight = CreateTempIpoint(atk, Location(oArea, vRight, fFacing + 180.0));
				SetScale(oIpointRight, fMarkScaleWidth, fMarkScaleLength, 1.0);
				ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectNWN2SpecialEffectFile("specatk_shape_line"), oIpointRight);

				vector vEnd = vStart + vDirection * atk.range;
				object oIpointEnd = CreateTempIpoint(atk, Location(oArea, vEnd, fFacing));
				SetScale(oIpointEnd, fMarkScaleWidth, 1.0, 1.0);
				ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectNWN2SpecialEffectFile("specatk_shape_line_end"), oIpointEnd);

				object oIpointStart = CreateTempIpoint(atk, Location(oArea, vStart, fFacing));
				SetScale(oIpointStart, fMarkScaleWidth, 1.0, 1.0);
				ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectNWN2SpecialEffectFile("specatk_shape_line_start"), oIpointStart);

				//Ipoint & script
				_CallScript(atk, SPECATK_EVENT_PREPARE, oIpointEnd);
				DelayCommand(atk.delay, _Impact(atk, oIpointEnd));

				//Visualize limits
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(oArea, vStart+vDirection*atk.range, 0.0), atk.delay);
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(oArea, vLeft, 0.0), atk.delay);
				// ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_holy_ray"), Location(oArea, vRight, 0.0), atk.delay);
			}
			break;

		case SPECATK_SHAPE_CONE:
			{
				object oArea = GetAreaFromLocation(atk.loc);
				vector vO = GetPositionFromLocation(atk.loc);
				float fFacing = GetFacingFromLocation(atk.loc);
				float fOffsetCone = atk.width < 60.0? 1.0 / cos(atk.width) : 0.0;

				float fFacingLeft = fFacing + atk.width;
				vector vDirectionLeft = AngleToVector(fFacingLeft);
				vector vIpointLeft = vO + vDirectionLeft * (fOffsetCone + (atk.range - fOffsetCone) / 2.0);
				object oIpointLeft = CreateTempIpoint(atk, Location(oArea, vIpointLeft, fFacingLeft));
				SetScale(oIpointLeft, 2.0, (atk.range - fOffsetCone) / 10.0, 1.0);
				ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectNWN2SpecialEffectFile("specatk_shape_line"), oIpointLeft);

				float fFacingRight = fFacing - atk.width;
				vector vDirectionRight = AngleToVector(fFacingRight);
				vector vIpointRight = vO + vDirectionRight * (fOffsetCone + (atk.range - fOffsetCone) / 2.0);
				object oIpointRight = CreateTempIpoint(atk, Location(oArea, vIpointRight, fFacingRight+180.0));
				SetScale(oIpointRight, 2.0, (atk.range - fOffsetCone) / 10.0, 0.5);
				ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectNWN2SpecialEffectFile("specatk_shape_line"), oIpointRight);

				if(atk.width < 60.0){
					object oIpointStart = CreateTempIpoint(atk, atk.loc);
					SetScale(oIpointStart, 2.0 * tan(atk.width), 2.0, 1.0);
					ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectNWN2SpecialEffectFile("specatk_shape_line_end"), oIpointStart);

					if(atk.width > 25.0){
						object oIpointMiddle = CreateTempIpoint(atk, atk.loc);
						SetScale(oIpointMiddle, 2.0, atk.range / 10.0, 1.0);
						ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectNWN2SpecialEffectFile("specatk_shape_cone_fill"), oIpointMiddle);
					}
				}
				else{
					float fAngleToFill = (atk.width - 15.0) * 2.0;
					int nFillConeCount = FloatToInt(fAngleToFill / 45.0);
					if(nFillConeCount == 0)
						nFillConeCount = 1;
					float fDelta = fAngleToFill / (nFillConeCount*1.0);

					int i;
					for(i = 0 ; i < nFillConeCount ; i++){
						float fIpointFacing = fFacing - atk.width + 15.0 + (i + 0.5) * fDelta;

						object oIpoint = CreateTempIpoint(atk, Location(oArea, vO, fIpointFacing));
						SetScale(oIpoint, atk.range / 10.0, atk.range / 10.0, 1.0);
						ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectNWN2SpecialEffectFile("specatk_shape_cone_fill"), oIpoint);
					}
				}


				//Ipoint & script
				object oIpoint = CreateTempIpoint(atk, atk.loc);
				SetScale(oIpoint, atk.range, atk.range, atk.range);

				_CallScript(atk, SPECATK_EVENT_PREPARE, oIpoint);
				DelayCommand(atk.delay, _Impact(atk, oIpoint));
			}
			break;

		default:
			SendMessageToPC(OBJECT_SELF, "BUG: Shape "+IntToString(atk.shape)+" not implemented in _Prepare()");
	}
}

float _GetSideFromLine(vector vA, vector vB, vector vPoint){
	float fA = - (vB.y - vA.y);
	float fB = vB.x - vA.x;
	float fC = - (fA * vA.x + fB * vA.y);
	return fA * vPoint.x + fB * vPoint.y + fC;
}

void _Impact(struct SpecAtkProperties atk, object oTarget){
	int nNextImpactDelay = _CallScriptInt(atk, SPECATK_EVENT_IMPACT, oTarget);
	if(nNextImpactDelay > 0){
		float fNextImpactDelay = nNextImpactDelay / 1000.0;
		DelayCommand(fNextImpactDelay, _Impact(atk, oTarget));
	}
	else{
		_DestroyRegisteredObjects(atk);
		AssignCommand(atk.var_container, DelayCommand(6.0, DestroyObject(atk.var_container)));
	}

	switch(atk.shape){
		case SPECATK_SHAPE_NONE:
			break;
		case SPECATK_SHAPE_CIRCLE:
			{
				object oNear = GetFirstObjectInShape(SHAPE_SPHERE, atk.range, atk.loc);
				while(GetIsObjectValid(oNear)){

					_CallScript(atk, SPECATK_EVENT_HIT, oNear);

					oNear = GetNextObjectInShape(SHAPE_SPHERE, atk.range, atk.loc);
				}
			}
			break;

		case SPECATK_SHAPE_LINE:
			{
				// A--------------------B/
				// O                    <=
				// C--------------------D\
				vector vO = GetPositionFromLocation(atk.loc);
				float fFacing = GetFacingFromLocation(atk.loc);
				vector vDirection = AngleToVector(fFacing);
				vector vPerpendicular = AngleToVector(fFacing + 90.0);

				vector vA = vO - vPerpendicular * (atk.width / 2.0);
				vector vB = vA + vDirection * atk.range;
				vector vC = vO + vPerpendicular * (atk.width / 2.0);
				vector vD = vC + vDirection * atk.range;

				object oNear = GetFirstObjectInShape(SHAPE_SPHERE, atk.range, atk.loc);
				while(GetIsObjectValid(oNear)){

					vector vNear = GetPosition(oNear);
					if(_GetSideFromLine(vA, vB, vNear) >= 0.0
					&& _GetSideFromLine(vC, vD, vNear) <= 0.0
					&& _GetSideFromLine(vA, vC, vNear) <= 0.0){
						_CallScript(atk, SPECATK_EVENT_HIT, oNear);
					}

					oNear = GetNextObjectInShape(SHAPE_SPHERE, atk.range, atk.loc);
				}
			}
			break;

		case SPECATK_SHAPE_CONE:
			{
				//   __-- A
				// O __
				//     -- B
				vector vO = GetPositionFromLocation(atk.loc);
				float fFacing = GetFacingFromLocation(atk.loc);
				vector vA = vO + AngleToVector(fFacing - atk.width) * atk.range;
				vector vB = vO + AngleToVector(fFacing + atk.width) * atk.range;

				object oNear = GetFirstObjectInShape(SHAPE_SPHERE, atk.range, atk.loc);
				while(GetIsObjectValid(oNear)){

					vector vNear = GetPosition(oNear);
					if((atk.width <= 90.0
					&& _GetSideFromLine(vO, vA, vNear) >= 0.0 && _GetSideFromLine(vO, vB, vNear) <= 0.0)
					|| (atk.width > 90.0
					&& (_GetSideFromLine(vO, vA, vNear) >= 0.0 || _GetSideFromLine(vO, vB, vNear) <= 0.0))){

						_CallScript(atk, SPECATK_EVENT_HIT, oNear);
					}

					oNear = GetNextObjectInShape(SHAPE_SPHERE, atk.range, atk.loc);
				}
			}
			break;

		default:
			SendMessageToPC(OBJECT_SELF, "BUG: Shape "+IntToString(atk.shape)+" not implemented in _Impact()");
	}
}

void CastSpecialAttack(string sAtkScript, location lLoc, float fDelay, int nShape, float fRange, float fWidth = 0.0){
	struct SpecAtkProperties atk;
	atk.script = sAtkScript;
	atk.loc = lLoc;
	atk.delay = fDelay;
	atk.shape = nShape;
	atk.range = fRange;
	atk.width = fWidth;
	atk.var_container = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_ipoint ", lLoc);

	_Prepare(atk);
}


object CreateTempIpoint(struct SpecAtkProperties atk, location lLocation){
	object oIpoint = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_ipoint ", lLocation);
	_RegisterObjectToDestroy(atk, oIpoint);
	return oIpoint;
}


int GetIsInShape(location lPoint, location lShape, int nShape, float fRange, float fWidth){
	switch(nShape){
		case SPECATK_SHAPE_NONE:
			break;
		case SPECATK_SHAPE_CIRCLE:
			{
				GetDistanceBetweenLocations(lShape, lPoint);
			}
			break;

		case SPECATK_SHAPE_LINE:
			{
				// A--------------------B/
				// O                    <=
				// C--------------------D\
				vector vO = GetPositionFromLocation(lShape);
				float fFacing = GetFacingFromLocation(lShape);
				vector vDirection = AngleToVector(fFacing);
				vector vPerpendicular = AngleToVector(fFacing + 90.0);

				vector vA = vO - vPerpendicular * (fWidth / 2.0);
				vector vB = vA + vDirection * fRange;
				vector vC = vO + vPerpendicular * (fWidth / 2.0);
				vector vD = vC + vDirection * fRange;

				vector vNear = GetPositionFromLocation(lPoint);
				return _GetSideFromLine(vA, vB, vNear) >= 0.0
				    && _GetSideFromLine(vC, vD, vNear) <= 0.0
				    && _GetSideFromLine(vA, vC, vNear) <= 0.0;
			}
			break;

		case SPECATK_SHAPE_CONE:
			{
				//   __-- A
				// O __
				//     -- B
				vector vO = GetPositionFromLocation(lShape);
				float fFacing = GetFacingFromLocation(lShape);
				vector vA = vO + AngleToVector(fFacing - fWidth) * fRange;
				vector vB = vO + AngleToVector(fFacing + fWidth) * fRange;

				vector vNear = GetPositionFromLocation(lPoint);
				return (fWidth <= 90.0
				    && _GetSideFromLine(vO, vA, vNear) >= 0.0 && _GetSideFromLine(vO, vB, vNear) <= 0.0)
				    || (fWidth > 90.0
				    && (_GetSideFromLine(vO, vA, vNear) >= 0.0 || _GetSideFromLine(vO, vB, vNear) <= 0.0));
			}
			break;

		default:
			SendMessageToPC(OBJECT_SELF, "BUG: Shape "+IntToString(nShape)+" not implemented in GetIsInShape()");
	}
	return FALSE;
}
