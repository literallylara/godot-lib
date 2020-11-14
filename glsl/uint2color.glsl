vec4 uint2color(uint v)
{
	float a = float(v & uint(255));
	v >>= uint(8);
	float b = float(v & uint(255));
	v >>= uint(8);
	float g = float(v & uint(255));
	v >>= uint(8);
	float r = float(v & uint(255));
	
	return vec4(r,g,b,a)/255.;
}