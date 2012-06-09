/**
 * Simon is the legal property of its developers, whose names are too
 * numerous to list here.  Please refer to the COPYRIGHT file
 * distributed with this source distribution.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */


//------------------------------------------------------------------------------
/**
 *  \class Quaternion
 *  \author Achilles, Baierl, Koehler
 *
 * \brief Quaternion-Klasse
 *
* Man benutzt Einheits(!!)-Quaternionen, um Rotationen zu berechnen. Ein Quaternion hat die Form q=(w, v),
* wobei w ein Skalar und v=(x, y, z) ein Vektor ist.
* Um z.B. einen Punkt P=(a, b, c) um einen Winkel angle und eine Achse axis zu rotieren, erstellt man sich
* aus dem Vektor P ein pures Quaternion p und aus axis und angle ein RotationsQuaternion q.
* Den Punkt P rotiert man nun indem man rechnet: qpq* (q* ist die Inverse von q).
*
* Um die Umrechnung bei Quaternionen (Eulerwinkel, Matrizen) konsistent zu halten, 
* muss man festlegen, welche Reihenfolge bei den Eulerwinkeln zu Grunde liegt.
* Daher _Konvention_ hier: Rz(phiz)*Ry(phiy)*Rx(phix), d.h. es wird erst um x rotiert, dann um y, dann um z. Und zwar
* jeweils um die * entsprechenden Winkel phix, phiy, phiz.
*
* Anmerkungen: Zu mglichen Konventionen siehe "Ken Shoemake: Euler Angle Conversion", GraphicsGems IV, Kapitel III.5,
* Seiten 222-229. 
*
* Getestete Funktionen:
* -Euler-Konstruktor
* -getEulerRotation
* -getRotationMatrix
*
* \todo Andere Funktionen testen (mit Testprogramm)
*/

import std.math;
import hurt.conv.conv;

struct vec3(T) {
	T values[3];
	
	this(T a, T b, T c) {
		values[0] = a;
		values[1] = b;
		values[2] = c;
	}

	void normalize() {
		double len = sqrt((values[0] * values[0]) + 
			(values[1] * values[1]) +
			(values[2] * values[2]));

		values[0] = values[0] / len;
		values[1] = values[1] / len;
		values[2] = values[2] / len;
	}
}

/**
* \brief Default-Konstruktor
*/

public struct Quaternion(T = float) {
	immutable Quaternion identity;
	T elements[4];

	this() {
		element[0] = 0.0;
		element[1] = 0.0;
		element[2] = 1.0;
		element[3] = 0.0;
	}

	/**
	* \brief Konstruktor, der als Input die vier einzelnen Komponenten eines Quaternions hat
	* \
	*/
	this(T w, T x, T y, T z){
		element[0] = w;
		element[1] = x;
		element[2] = y;
		element[3] = z;
	}

	/**
	* \brief Konstruktor, der aus einem Winkel (angle im Bogenma) und der Rotationsachse (axis) ein RotationsQuaternion erstellt. Die RotationsAchse wird normalisiert
	*
	* \param float angle Bogenma der Drehung.
	* \param vec3!T axis
	*/
	this(T angle, vec3!T axis){
		double tempSin = sin(conv!(T,double)angle / 2.f);
		axis.normalize();
		element[0] = cos(angle / 2.f);
		element[1] = axis[0] * tempSin;
		element[2] = axis[1] * tempSin;
		element[3] = axis[2] * tempSin;

	}

	/**
	* \brief Konstruktor, der als Input die Eulerwinkel hat (im Bogenma)
	* \param float phix, phiy, phiz (Eulerwinkel im Bogenma)
	*
	* Konvention: Rz*Ry*Rx !!! (s.o.)
	* Angepasster Code aus OpenSG Quaternionen... 
	*
	* Idee: Ein Quaternion reprsentiert eine Rotation durch
	* [cos(phi/2),sin(phi/2)*Rotationsachse]. Daher kann man die Eulerwinkel in Quaternionen umrechnen, indem man fr
	* jede Euler-Rotationsachse ein eigenes Quaternion erstellt, und diese Quaternionen multipliziert.
	* Dabei ist fr die Reihenfolge der Rotationen zu beachten: Q1*Q2*Q3 bedeutet, das zunchst die Q3-Rotation angewendet 
	* wird, danach Q2, danach Q1.
	* Der Code dieser Funktion ist die ausformulierte Muliplikation der Quaternionen.
	*/
	this(T phix, T phiy, T phiz){
		
		double sx = sin(phix * 0.5);
		double cx = cos(phix * 0.5);

		double sy = sin(phiy  * 0.5);
		double cy = cos(phiy  * 0.5);
		
		double sz = sin(phiz * 0.5);
		double cz = cos(phiz * 0.5);

		element[0] = (cx * cy * cz) + (sx * sy * sz);
		element[1] = (sx * cy * cz) - (cx * sy * sz);
		element[2] = (cx * sy * cz) + (sx * cy * sz);
		element[3] = (cx * cy * sz) - (sx * sy * cz);
	}

	/**
	* \brief Konstruktor, der ein aus einem Vektor ein pures Quaternion erstellt
	* \param vec3!T v (Vektor, z.B. ein Punkt, der rotiert werden soll)
	* \todo Ahhhrg. Was mach das ding und wieso? bitte besser kommentieren oder entfernen.
	*/
	this(vec3!T v){
		element[0] = 0;
		element[1] = v[0];
		element[2] = v[1];
		element[3] = v[2];
	}


/**
* \brief Konstruktor, der als Input eine Rotationsmatrix hat
* \todo Was macht der Kram. Bitte Einheiten und Vorgehen kurz kommentieren.

Quaternion::Quaternion(Matrix3x3& m){

	float tr, s;

	tr = m[0][0] + m[1][1] + m[2][2];

	if (tr >= 0){
		s = sqrt(tr + 1);
		element[0] = 0.5f * s;
		s = 0.5f / s;
		element[1] = (m[2][1] - m[1][2]) * s;
		element[2] = (m[0][2] - m[2][0]) * s;
		element[3] = (m[1][0] - m[0][1]) * s;
	}

	else {
		int i = 0;
			
		if(m[1][1] > m[0][0])
			i = 1;
		if(m[2][2] > m[i][i])
			i = 2;

		switch (i){

		case 0:
			s = sqrt((m[0][0] - (m[1][1] + m[2][2])) + 1);
			element[1] = 0.5f * s;
			s= 0.5f / s;
			element[2] = (m[0][1] + m[1][0]) * s;
			element[3] = (m[2][0] + m[0][2]) * s;
			element[0] = (m[2][1] - m[1][2]) * s;
			break;

		case 1:
			s = sqrt((m[1][1] - (m[2][2] + m[0][0])) + 1);
			element[2] = 0.5f * s;
			s = 0.5f / s;
			element[3] = (m[1][2] + m[2][1]) * s;
			element[1] = (m[0][1] + m[1][0]) * s;
			element[0] = (m[0][2] - m[2][0]) * s;
			break;

		case 2:
			s = sqrt((m[2][2] - (m[0][0] + m[1][1])) + 1);
			element[3] = 0.5f * s;
			s = 0.5f / s;
			element[1] = (m[2][0] + m[0][2]) * s;
			element[2] = (m[1][2] + m[2][1]) * s;
			element[0] = (m[1][0] - m[0][1]) * s;
		}
	}		

}*/


	/**
	* \brief Destruktor
	*/
	~this() {
	}

	/**
	* \brief Gibt gewnschtes Element des Quaternions zurck
	*/
	T opIndex(size_t index) const {
	   return element[index];
	}

	/**
	* \brief Gibt gewnschtes Element des Quaternions zurck
	
	const float& Quaternion::operator [](unsigned int index) const{
	   return element[index];
	}*/


	/**
	* \brief elementweise Addition zweier Quaternionen 
	* \param Quaternion
	* \return Quaternion
	*/
	Quaternion opOpAssign!("+=")(const Quaternion rhs){
		element[0] += rhs.element[0];
		element[1] += rhs.element[1];
		element[2] += rhs.element[2];
		element[3] += rhs.element[3];

	   return this;
	}

	/**
	* \brief Multiplikation zweier Quaternionen
	* \param Quaternion
	* \return Quaternion
	*/
	Quaternion opOpAssign!("*=")(const Quaternion rhs){
		//! \todo Das geht bestimmt besser, oder?
		Quaternion temp = this * rhs;
		this = temp;
		
		return *this;
	}


	/**
	* \brief Identitts-Quaternion fr die Multiplikation
	*/
	void identity() {
		element[0] = 1.0;
		element[1] = 0.0;
		element[2] = 0.0;
		element[3] = 0.0;
	}

	/**
	* \brief Gibt das inverse Quaternion zurck
	* \return Invertiertes Quaternion
	*/
	Quaternion inverse() {
		return Quaternion(element[0], 
			-element[1], 
			-element[2], 
			-element[3]);
	}

	/**
	* \brief Invertiert das Quaternion, setz es jedoch nicht
	*/
	void invert() {
		element[1] = -element[1];
		element[2] = -element[2];
		element[3] = -element[3];
	}

	/**
	* \brief Normalisiert das Quaternion
	* \return Gibt die Magnitude (Norm) zurck (float)
	*/
	T normalize() {
		if(element[0] == 0.0 && element[1] == 0.0 && 
				element[2] == 0.0 && element[3] == 0.0) {
			return 0.0;
		}

		const float norm = sqrt(element[0] * element[0] + 
			element[1] * element[1] + 
			element[2] * element[2] + 
			element[3] * element[3]);
		
		//assert(norm == 0.0);

		for(int i=0; i<4; ++i) {
			element[i] /= norm;
		}
		return norm;
	}

	/**
	* \brief Normalisiert die Rotationsachse eines Orientierungs-Quaternions (noch nicht sicher ob ntig)
	*/
	void normalizeAxis() {
		float denom = sqrt(1 - (element[0]*element[0]));
		T x = element[1]/denom;
		T y = element[2]/denom;
		T z = element[3]/denom;
		vec3!T axis = vec3!T(x, y, z);
		axis.normalize();
		element[1] = axis[0]*denom;
		element[2] = axis[1]*denom;
		element[3] = axis[2]*denom;
	}

	/**
	* \brief Setzt die Werte des Quaternions, hat als Input die vier einzelnen Komponenten eines Quaternions
	*/
	void setValues(T w, T x, T y, T z){
		element[0] = w;
		element[1] = x;
		element[2] = y;
		element[3] = z;
	}

	/**
	* \brief Setzt die WErte des RotationsQuaternion aus Winkel (angle im Bogenma) und der Rotationsachse (axis) neu
	*
	* \param float angle Bogenma der Drehung.
	* \param vec3!T axis
	*/
	void setValues(T angle, vec3!T axis){
		float tempSin = sin(angle / 2);

		element[0] = cosf(angle / 2);
		element[1] = axis[0] * tempSin;
		element[2] = axis[1] * tempSin;
		element[3] = axis[2] * tempSin;
	}


	/**
	* \brief Setzt die Werte des Quaternions, hat als Input die Eulerwinkel
	* \param float x, y, z die Eulerwinkel in Bogenma
	*/
	void setValues(T x, T y, T z) {
		this = Quaternion(x, y, z);
	}

	/**
	* \brief setzt die Werte des Vektorteils im Quaternion neu
	* \return Setzt die Werte in den bergebenen Referenzen
	*/
	void setVector(const vec3!T v) {
		element[1] = v[0];
		element[2] = v[1];
		element[3] = v[2];
	}

	/**
	* \brief Gibt die Werte des Quaternion in der Achsen- und Winkel-Form zurck
	* \return Setzt die Werte in den bergebenen Referenzen
	*/
	void getAxisAngle(ref vec3!T axis, ref T angle) const {
		float s = sqrt(
			(element[1] * element[1]) + 
			(element[2] * element[2]) + 
			(element[3] * element[3]));

		if(s == 0) {
			axis[0] = 1;
			axis[1] = 0;
			axis[2] = 0;

			angle = 0;
		} else {
			axis[0] = element[1] / s;
			axis[1] = element[2] / s;
			axis[2] = element[3] / s;

			angle = 2 * acos(element[0]);
		}
	}

	//! \return The axis of rotation
	vec3!T getAxis() const {
		float s = sqrt(
			(element[1] * element[1]) + 
			(element[2] * element[2]) + 
			(element[3] * element[3]));

		vec3!T axis;
			
		if(s == 0) {
			axis[0] = 1;
			axis[1] = 0;
			axis[2] = 0;
		} else {
			axis[0] = element[1] / s;
			axis[1] = element[2] / s;
			axis[2] = element[3] / s;
		}

		return axis;
	}

	//! \return The angle of rotation in radian
	double getAngle() const {
		double s = sqrt(
			(element[1] * element[1]) + 
			(element[2] * element[2]) + 
			(element[3] * element[3]));
		double angle;

		if(s == 0) {
			angle = 0;
		} else {
			angle = 2 * acos(element[0]);
		}
		return angle;
	}

	/**
	* \brief Gibt die einzelnen 4 Komponenten des Quaternions zurck
	* \return Setzt die Werte in die bergebenen Referenzen
	*/
	void getValues(ref float w, ref float x, ref float y, ref float &) const {
		w = element[0];
		x = element[1];
		y = element[2];
		z = element[3];
	}

	T w() const {
		return element[0];
	}

	T x() const {
		return element[1];
	}

	T y() const {
		return element[2];
	}
	T z() const {
		return element[3];
	}

	/**
	* \brief Gibt den Vektor des Quaternions zurck
	* \return vec3!T
	*/
	vec3!T getVector() const{
		return vec3!T(element[1], element[2], element[3]);
	}

	/**
	* \brief Gibt die Werte des Quaternions als Euler Winkel zurck (im Bogenma)
	* \return vec3!T (Euler-Winkel des Quaternions)
	*
	* Konvention: Rz*Ry*Rx !!! (s.o.)
	* Angepasster Code aus GraphicsGems IV, Kapitel III.5 (Euler-Angle-Conversion)
	*
	* Idee:
	* getRotationMatrix liefert eine Matrix. Diese Matrix ist eben jene, die man erhlt, wenn man drei
	* Rotationsmatrizen (jeweils um z, y, x-Achse) in der Reihenfolge Rz*Ry*Rx multipliziert. atan2(b,a) rechnet
	* intern atan(b/a). Dementsprechend werden aus der Matrix Werte so an atan2 bergeben, das b/a im Endeffekt 
	* sinx/cosx=tanx (bzw. tany, tanz) ergibt.
	* a und b werden so aus der Matrix gewhlt, dass sich cos(phiy) immer wegkrzt. Daher muss der cos(phiy)=0 abgefangen 
	* werden (else-Zweig). Dies ist fr rotationY nicht mglich, daher muss hier cos(phiy) anders berechnet werden. Hierzu wird 
	* die Formel cos^2(phi)+sin^2(phi)=1 angewandt.
	* 
	*/
	vec3!T getEulerRotation() const {

		vec3!T rotation;

		Matrix3x3 m;
		getRotationMatrix(m);
		float cosY = sqrt(m[0][0]*m[0][0]+m[1][0]*m[1][0]);
		
		if (cosY > 16 * FLT_EPSILON) {
			rotation[0] = atan2(1.0f*m[2][1], m[2][2]);
			rotation[1] = atan2(-1.0f*m[2][0], cosY);
			rotation[2] = atan2(1.0f*m[1][0], m[0][0]);
		} else {
			rotation[0] = atan2(-1.0f*m[1][2], m[1][1]);
			rotation[1] = atan2(-1.0f*m[2][0], cosY);
			rotation[2] = 0.0;
		}
		
		assert(!ISNAN(rotation[0]));
		assert(!ISNAN(rotation[1]));
		assert(!ISNAN(rotation[2]));

		return rotation;
	}

	/**
	* \brief Formt das Quaternion in eine Rotationsmatrix um
	* \param Matrix3x3 (3x3Rotationsmatrix)
	* Konvention: Rz*Ry*Rx !!! (s.o.)
	*
	* Die Werte im Quaternion entsprechen Multiplikationen der verschiedenen Cosinus- und Sinuswerte. Daher kann man durch
	* geschicktes Vorgehen diese Sinus-/Cosinuswerte rckrechnen. Dabei werden die Quaternionenwerte so geschickt zusammen-
	* gerechnet, das sich aufgrund der Trigonometrischen Gesetzmssigkeiten im Endeffekt die Eintrge der Rotationsmatrix 
	* Rz*Ry*Rx ergeben.
	* 
	* Diesen Code haben wir nicht bis ins letzte Detail nachvollzogen, ihn allerdings durch ausfhrliche Vergleichstests besttigt.
	*
	* Dieser Code wurde aus OpenSG bernommen. OpenSG rechnet anscheinend mit transponierten Matrizen, daher wird die
	* Ergebnismatrix "zurck"-transponiert.
	
	void getRotationMatrix(Matrix3x3 &matrix) const{

		assert(matrix.getSizeM () == 3 && matrix.getSizeN () == 3);

		matrix[0][0] = 1.0f - 2.0f * (element[2] * element[2] +element[3] * element[3]);
		matrix[0][1] = 2.0f * (element[1] * element[2] +element[3] * element[0]);
		matrix[0][2] = 2.0f * (element[3] * element[1] -element[2] * element[0]);

		matrix[1][0] = 2.0f * (element[1] * element[2] -element[3] * element[0]);
		matrix[1][1] = 1.0f - 2.0f * (element[3] * element[3] +element[1] * element[1]);
		matrix[1][2] = 2.0f * (element[2] * element[3] +element[1] * element[0]);

		matrix[2][0] = 2.0f * (element[3] * element[1] +element[2] * element[0]);
		matrix[2][1] = 2.0f * (element[2] * element[3] -element[1] * element[0]);
		matrix[2][2] = 1.0f - 2.0f * (element[2] * element[2] +element[1] * element[1]);

		matrix = matrix.T();

	}

	//! \see getRotationMatrix(Matrix3x3)
	Matrix3x3 Quaternion::getRotationMatrix() const{
		
		Matrix3x3 matrix;
		getRotationMatrix(matrix);
		return matrix;
	}*/

	/**
	* \brief Gibt die Werte des Quaternions aus
	*/
	void Quaternion::print() {
		//cout << "Quaternion: " << element[0] << " (" << element[1] << " " << element[2] << " " << element[3] << ") "<< endl;
	}


	//--- Related functions --------------------------------------------------------

	/**
	* \brief Multiplikation zweier Quaternionen
	* \return neues Quaterion
	*/
	Quaternion opBinary("*")(const Quaternion rhs) const {

		return Quaternion(this[0] * rhs[0] - this[1] * rhs[1] - this[2] * rhs[2] - this[3] * rhs[3],
							this[1] * rhs[0] + this[0] * rhs[1] + this[2] * rhs[3] - this[3] * rhs[2],
							this[2] * rhs[0] + this[0] * rhs[2] + this[3] * rhs[1] - this[1] * rhs[3],
							this[3] * rhs[0] + this[0] * rhs[3] + this[1] * rhs[2] - this[2] * rhs[1]);

	}

	/**
	* \brief Addition zweier Quaternionen
	* \return neues Quaterion
	*/
	Quaternion opBinary("+")(const Quaternion rhs) const {
		return Quaternion(
			this[0] + rhs[0],
			this[1] + rhs[1],
			this[2] + rhs[2],
			this[3] + rhs[3]);
	}


	/**
	* \brief Multiplikation von Skalar und Quaternion
	* \return neues Quaterion
	*/
	Quaternion opBinary("*")(const float f, const Quaternion& q){
		return Quaternion(
			f * q[0],
			f * q[1],
			f * q[2],
			f * q[3]);
	}

	/**
	* \brief Multiplikation von Quaternion und Skalar
	* \return neues Quaterion
	*/
	Quaternion opBinary("*")(const T f) const {
		return Quaternion(
			f * this[0],
			f * this[1],
			f * this[2],
			f * this[3]);
	}

	/**
	* \brief POunktprodukt von Quaternionen
	* \return neues float
	*/

	T dot(const Quaternion rhs) const {
		return this[0] * rhs[0] +
			this[1] * rhs[1] +
			this[2] * rhs[2] +
			this[3] * rhs[3];
	}


	/**
	* \brief Rotation von Vektor um Orientierungs-Quaternion 
	* \param vector ein Vektor
	* \param quat das Orientierungs-Quaternion, um welches gedreht wird 
	* \return um Quaternion rotierter Vektor
	*/
	vec3!T qRotate(const vec3!T vector, const Quaternion qRot) {
		Quaternion qInvRot = qRot;
		qInvRot.invert();
		Quaternion qVector(vector);
		qVector = qRot * qVector * qInvRot;
		
		return vec3!T(qVector[1], qVector[2], qVector[3]);
	} 

/*std::ostream& operator <<(std::ostream& os, const Quaternion& quaternion) {
	//Werte des QUaternions pur ausgeben
	os << "W: " << quaternion[0] << ", ";
	os << "X: " << quaternion[1] << ", ";
	os << "Y: " << quaternion[2] << ", ";
	os << "Z: " << quaternion[3] << "    oder:    ";

	vec3!T vec;
	float ang;
	quaternion.getAxisAngle(vec, ang);

	os << "Winkel: " << ang << " Achse: " << vec;
	
	return os;
}*/
