module hurt.math.quaternion;
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

/**
* \brief Default-Konstruktor
*/

import hurt.math.vec;
import hurt.math.matrix;
import std.math;
import hurt.conv.conv;

//#define	DEGTORAD(x)	( ((x) * M_PI) / 180.0f )
//#define	RADTODEG(x)	( ((x) * 180.0f) / M_PI )

double degToRad(double deg) {
	return (deg * PI) / 180.0;
}

double radToDeg(double rad) {
	return (rad * 180.0) / PI;
}

struct Quaternion(T) {
	private T mqElement[4];

		this(this) {
		mqElement[0] = 0.0;
		mqElement[1] = 0.0;
		mqElement[2] = 0.0;
		mqElement[3] = 1.0;
	}

/**
* \brief Konstruktor, der als Input die vier einzelnen Komponenten eines Quaternions hat
* \
*/
	this(T w, T x, T y, T z){
		mqElement[0] = w;
		mqElement[1] = x;
		mqElement[2] = y;
		mqElement[3] = z;
	}

/**
* \brief Konstruktor, der aus einem Winkel (angle im Bogenma) und der Rotationsachse (axis) ein RotationsQuaternion erstellt. Die RotationsAchse wird normalisiert
*
* \param float angle Bogenma der Drehung.
* \param vec3!T axis
*/
	this(T angle, vec3!T axis){
		float tempSin = sin(conv!(T,real)(angle) / 2.0);
		axis.normalize();
		mqElement[0] = cos(conv!(T,real)(angle) / 2.0);
		mqElement[1] = axis[0] * tempSin;
		mqElement[2] = axis[1] * tempSin;
		mqElement[3] = axis[2] * tempSin;
	
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
		T sx = sin(phix * 0.5f);
		T cx = cos(phix * 0.5f);

		T sy = sin(phiy  * 0.5f);
		T cy = cos(phiy  * 0.5f);
		
		T sz = sin(phiz * 0.5f);
		T cz = cos(phiz * 0.5f);

		mqElement[0] = (cx * cy * cz) + (sx * sy * sz);
		mqElement[1] = (sx * cy * cz) - (cx * sy * sz);
		mqElement[2] = (cx * sy * cz) + (sx * cy * sz);
		mqElement[3] = (cx * cy * sz) - (sx * sy * cz);
	}

	/**
	* \brief Konstruktor, der ein aus einem Vektor ein pures Quaternion erstellt
	* \param vec3!T v (Vektor, z.B. ein Punkt, der rotiert werden soll)
	* \todo Ahhhrg. Was mach das ding und wieso? bitte besser kommentieren oder entfernen.
	*/
	this(vec3!T v){
	    mqElement[0] = 0;
		mqElement[1] = v[0];
		mqElement[2] = v[1];
		mqElement[3] = v[2];
	
	}

	/**
	* \brief Konstruktor, der als Input eine Rotationsmat hat
	* \todo Was macht der Kram. Bitte Einheiten und Vorgehen kurz kommentieren.
	*/
	this(mat!(T,3,3) m) {
	
		T tr, s;
	
		tr = m[0,0] + m[1,1] + m[2,2];
	
		if(tr >= 0) {
			s = sqrt(tr + 1);
			mqElement[0] = 0.5f * s;
			s = 0.5f / s;
			mqElement[1] = (m[2,1] - m[1,2]) * s;
			mqElement[2] = (m[0,2] - m[2,0]) * s;
			mqElement[3] = (m[1,0] - m[0,1]) * s;
		} else {
			int i = 0;
				
			if(m[1,1] > m[0,0])
				i = 1;
			if(m[2,2] > m[i,i])
				i = 2;
	
			switch(i) {
				case 0:
					s = sqrt(cast(real)(m[0,0] - (m[1,1] + m[2,2])) + 1);
					mqElement[1] = 0.5f * s;
					s= 0.5f / s;
					mqElement[2] = (m[0,1] + m[1,0]) * s;
					mqElement[3] = (m[2,0] + m[0,2]) * s;
					mqElement[0] = (m[2,1] - m[1,2]) * s;
					break;
	
				case 1:
					s = sqrt(cast(real)(m[1,1] - (m[2,2] + m[0,0])) + 1);
					mqElement[2] = 0.5f * s;
					s = 0.5f / s;
					mqElement[3] = (m[1,2] + m[2,1]) * s;
					mqElement[1] = (m[0,1] + m[1,0]) * s;
					mqElement[0] = (m[0,2] - m[2,0]) * s;
					break;
	
				case 2:
					s = sqrt(cast(real)(m[2,2] - (m[0,0] + m[1,1])) + 1);
					mqElement[3] = 0.5f * s;
					s = 0.5f / s;
					mqElement[1] = (m[2,0] + m[0,2]) * s;
					mqElement[2] = (m[1,2] + m[2,1]) * s;
					mqElement[0] = (m[1,0] - m[0,1]) * s;
					break;
				default:
					assert(false);
			}
		}		
	}


	/**
	* \brief Destruktor
	*/
	~this() { 
	}

	/**
	* \brief Gibt gewnschtes Element des Quaternions zurck
	*/
	T opIndex(size_t index) {
		return mqElement[index];
	}

	/**
	* \brief Gibt gewnschtes Element des Quaternions zurck
	*/
	const float opIndex(size_t index) const {
	   return mqElement[index];
	}


	/**
	* \brief elementweise Addition zweier Quaternionen 
	* \param Quaternion
	* \return Quaternion
	*/
	Quaternion!T opOpAssign(string op)(const ref Quaternion!T rhs) {
		mixin("mqElement[0]"~ op ~ "rhs.mqElement[0]");
		mixin("mqElement[1]"~ op ~ "rhs.mqElement[1]");
		mixin("mqElement[2]"~ op ~ "rhs.mqElement[2]");
		mixin("mqElement[3]"~ op ~ "rhs.mqElement[3]");

	   return this;
	}

	Quaternion!T opAssign(Quaternion!T rhs) {
		mqElement[0] = rhs.mqElement[0];
		mqElement[1] = rhs.mqElement[1];
		mqElement[2] = rhs.mqElement[2];
		mqElement[3] = rhs.mqElement[3];
		return this;
	}

	Quaternion!T opAssign(const ref Quaternion!T rhs) {
		mqElement[0] = rhs.mqElement[0];
		mqElement[1] = rhs.mqElement[1];
		mqElement[2] = rhs.mqElement[2];
		mqElement[3] = rhs.mqElement[3];
		return this;
	}

	/**
	* \brief Gibt das inverse Quaternion zurck
	* \return Invertiertes Quaternion
	*/
	Quaternion!T inverse() {
		return Quaternion!T(mqElement[0], -mqElement[1], -mqElement[2], -mqElement[3]);
	}

	/**
	* \brief Invertiert das Quaternion, setz es jedoch nicht
	*/
	void invert() {
		mqElement[1] = -mqElement[1];
		mqElement[2] = -mqElement[2];
		mqElement[3] = -mqElement[3];
	}

	/**
	* \brief Normalisiert das Quaternion
	* \return Gibt die Magnitude (Norm) zurck (float)
	*/
	T normalize() {
		if(mqElement[0] == 0.0 && mqElement[1] == 0.0 && mqElement[2] == 0.0 && mqElement[3] == 0.0) {
			return conv!(float,T)(0.0);
		}

		const T norm = conv!(double,T)(sqrt(mqElement[0] * mqElement[0] + 
				mqElement[1] * mqElement[1] + 
				mqElement[2] * mqElement[2] + 
				mqElement[3] * mqElement[3]));
		
		//assert(norm == 0.0);

		for(int i=0; i<4; ++i) {
			mqElement[i] /= norm;
		}
		return norm;
	}

	/**
	* \brief Normalisiert die Rotationsachse eines Orientierungs-Quaternions (noch nicht sicher ob ntig)
	*/

	void normalizeAxis() {
		float denom = sqrt(1 - (mqElement[0]*mqElement[0]));
		float x = mqElement[1]/denom;
		float y = mqElement[2]/denom;
		float z = mqElement[3]/denom;
		vec3!T axis = vec3!T(x, y, z);
		axis.normalize();
		mqElement[1] = axis[0]*denom;
		mqElement[2] = axis[1]*denom;
		mqElement[3] = axis[2]*denom;
	}


	/**
	* \brief Setzt die Werte des Quaternions, hat als Input die vier einzelnen Komponenten eines Quaternions
	*/
	void setValues(T w, T x, T y, T z) {
		mqElement[0] = w;
		mqElement[1] = x;
		mqElement[2] = y;
		mqElement[3] = z;
	}

	/**
	* \brief Setzt die WErte des RotationsQuaternion aus Winkel (angle im Bogenma) und der Rotationsachse (axis) neu
	*
	* \param float angle Bogenma der Drehung.
	* \param vec3!T axis
	*/
	void setValues(T angle, vec3!T axis){
		float tempSin = sin(angle / 2);

		mqElement[0] = cos(angle / 2);
		mqElement[1] = axis[0] * tempSin;
		mqElement[2] = axis[1] * tempSin;
		mqElement[3] = axis[2] * tempSin;
	}


	/**
	* \brief setzt die Werte des Vektorteils im Quaternion neu
	* \return Setzt die Werte in den bergebenen Referenzen
	*/
	void setVector(const vec3!T v) {
		mqElement[1] = v[0];
		mqElement[2] = v[1];
		mqElement[3] = v[2];
	}

	/**
	* \brief Gibt die Werte des Quaternion in der Achsen- und Winkel-Form zurck
	* \return Setzt die Werte in den bergebenen Referenzen
	*/
	void getAxisAngle(ref vec3!T axis, ref float angle) const {
		T s = sqrt((mqElement[1] * mqElement[1]) + 
			(mqElement[2] * mqElement[2]) + 
			(mqElement[3] * mqElement[3]));

		if(s == 0) {
			axis[0] = 1;
			axis[1] = 0;
			axis[2] = 0;

			angle = 0;
		} else {
			axis[0] = mqElement[1] / s;
			axis[1] = mqElement[2] / s;
			axis[2] = mqElement[3] / s;

			angle = 2 * acos(mqElement[0]);
		}
	}

	//! \return The axis of rotation
	vec3!T getAxis() const {
		T s = sqrt((mqElement[1] * mqElement[1]) + 
			(mqElement[2] * mqElement[2]) + 
			(mqElement[3] * mqElement[3]));

		vec3!T axis;
			
		if(s == 0) {
			axis[0] = 1;
			axis[1] = 0;
			axis[2] = 0;
		} else {
			axis[0] = mqElement[1] / s;
			axis[1] = mqElement[2] / s;
			axis[2] = mqElement[3] / s;
		}

		return axis;
	}

	//! \return The angle of rotation in radian
	float getAngle() const {
		T s = sqrt((mqElement[1] * mqElement[1]) + 
			(mqElement[2] * mqElement[2]) + 
			(mqElement[3] * mqElement[3]));
		T angle;
		if(s == 0) {
			angle = 0;
		} else {
			angle = 2 * acos(mqElement[0]);
		}
		return angle;
	}

	/**
	* \brief Gibt die einzelnen 4 Komponenten des Quaternions zurck
	* \return Setzt die Werte in die bergebenen Referenzen
	*/
	void getValues(ref T w, ref T x, ref T y, ref T z) const {
		w = mqElement[0];
		x = mqElement[1];
		y = mqElement[2];
		z = mqElement[3];
	}

	T w() const {
		return mqElement[0];
	}

	T x() const {
		return mqElement[1];
	}

	T y() const {
		return mqElement[2];
	}

	T z() const {
		return mqElement[3];
	}

	/**
	* \brief Gibt den Vektor des Quaternions zurck
	* \return vec3!T
	*/
	vec3!T getVector () const{
		return vec3!T(mqElement[1], mqElement[2], mqElement[3]);
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
	void getEulerRotation(ref vec3!T rotation) const {
		mat!(T,3,3) m;
		getRotationMatrix(m);
		T cosY = sqrt(m[0,0]*m[0,0]+m[1,0]*m[1,0]);
		
		if(cosY > 16 * 0.00001) {
			rotation[0] = atan2(1.0f*m[2,1], m[2,2]);
			rotation[1] = atan2(-1.0f*m[2,0], cosY);
			rotation[2] = atan2(1.0f*m[1,0], m[0,0]);
		} else {
			rotation[0] = atan2(-1.0f*m[1,2], m[1,1]);
			rotation[1] = atan2(-1.0f*m[2,0], cosY);
			rotation[2] = 0.0;
		}
		
		assert(!isNaN(rotation[0]));
		assert(!isNaN(rotation[1]));
		assert(!isNaN(rotation[2]));
	}

	vec3!T getEulerRotation() const {
		vec3!T rotation;
		getEulerRotation(rotation);
		return rotation;
	}

	/**
	* \brief Formt das Quaternion in eine Rotationsmat um
	* \param Matrix3x3 (3x3Rotationsmat)
	* Konvention: Rz*Ry*Rx !!! (s.o.)
	*
	* Die Werte im Quaternion entsprechen Multiplikationen der verschiedenen Cosinus- und Sinuswerte. Daher kann man durch
	* geschicktes Vorgehen diese Sinus-/Cosinuswerte rckrechnen. Dabei werden die Quaternionenwerte so geschickt zusammen-
	* gerechnet, das sich aufgrund der Trigonometrischen Gesetzmssigkeiten im Endeffekt die Eintrge der Rotationsmat 
	* Rz*Ry*Rx ergeben.
	* 
	* Diesen Code haben wir nicht bis ins letzte Detail nachvollzogen, ihn allerdings durch ausfhrliche Vergleichstests besttigt.
	*
	* Dieser Code wurde aus OpenSG bernommen. OpenSG rechnet anscheinend mit transponierten Matrizen, daher wird die
	* Ergebnismat "zurck"-transponiert.
	*/
	void getRotationMatrix(ref mat!(T,3,3) mat) const {
		assert(mat.getSizeM() == 3 && mat.getSizeN() == 3);

		mat[0,0] = 1.0f - 2.0f * (mqElement[2] * mqElement[2] +mqElement[3] * mqElement[3]);
		mat[0,1] = 2.0f * (mqElement[1] * mqElement[2] +mqElement[3] * mqElement[0]);
		mat[0,2] = 2.0f * (mqElement[3] * mqElement[1] -mqElement[2] * mqElement[0]);

		mat[1,0] = 2.0f * (mqElement[1] * mqElement[2] -mqElement[3] * mqElement[0]);
		mat[1,1] = 1.0f - 2.0f * (mqElement[3] * mqElement[3] +mqElement[1] * mqElement[1]);
		mat[1,2] = 2.0f * (mqElement[2] * mqElement[3] +mqElement[1] * mqElement[0]);

		mat[2,0] = 2.0f * (mqElement[3] * mqElement[1] +mqElement[2] * mqElement[0]);
		mat[2,1] = 2.0f * (mqElement[2] * mqElement[3] -mqElement[1] * mqElement[0]);
		mat[2,2] = 1.0f - 2.0f * (mqElement[2] * mqElement[2] +mqElement[1] * mqElement[1]);

		mat = mat.tran();

	}

	//! \see getRotationMatrix(Matrix3x3)
	mat!(T,3,3) getRotationMatrix() const{
		mat!(T,3,3) mat;
		getRotationMatrix(mat);
		return mat;
	}

	/**
	* \brief Gibt die Werte des Quaternions aus
	*/
	void print() {
		hurt.util.slog.log("%f %f %f %f", mqElement[0],mqElement[1],mqElement[2],mqElement[3]);
	}


	//--- Related functions --------------------------------------------------------

	/**
	* \brief Multiplikation zweier Quaternionen
	* \return neues Quaterion
	*/
	Quaternion!T opBinary(string op)(const ref Quaternion rhs) const 
			if(op == "*") {
		return Quaternion!T (	this[0] * rhs[0] - this[1] * rhs[1] - this[2] * rhs[2] - this[3] * rhs[3],
							this[1] * rhs[0] + this[0] * rhs[1] + this[2] * rhs[3] - this[3] * rhs[2],
							this[2] * rhs[0] + this[0] * rhs[2] + this[3] * rhs[1] - this[1] * rhs[3],
							this[3] * rhs[0] + this[0] * rhs[3] + this[1] * rhs[2] - this[2] * rhs[1]);

	}

	/**
	* \brief Addition zweier Quaternionen
	* \return neues Quaterion
	*/
	Quaternion!T opBinary(string op)(const ref Quaternion!T rhs) const
			if(op == "+") {
		return Quaternion!T(
			this[0] + rhs[0],
			this[1] + rhs[1],
			this[2] + rhs[2],
			this[3] + rhs[3]);
	}


	/**
	* \brief Multiplikation von Skalar und Quaternion
	* \return neues Quaterion
	*/
	Quaternion!T opBinary(string op)(const T f) if(op == "*") {
		return Quaternion!T(
			f * q[0],
			f * q[1],
			f * q[2],
			f * q[3]);
	}

	/**
	* \brief POunktprodukt von Quaternionen
	* \return neues float
	*/

	float dot(const ref Quaternion!T lhs, const ref Quaternion!T rhs){
		return lhs[0] * rhs[0] +lhs[1] * rhs[1] +lhs[2] * rhs[2] +lhs[3] * rhs[3];
	}
}


/**
* \brief Rotation von Vektor um Orientierungs-Quaternion 
* \param vector ein Vektor
* \param quat das Orientierungs-Quaternion, um welches gedreht wird 
* \return um Quaternion rotierter Vektor
*/
static vec3!T qRotate(T)(const ref vec3!T vector, 
		const ref Quaternion!T qRot) {
	Quaternion!T qInvRot = qRot;
	qInvRot.invert();
	Quaternion!T qVector = Quaternion!T(vector);
	qVector = qRot * qVector * qInvRot;
	
	return vec3!T(qVector[1], qVector[2], qVector[3]);
} 
