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
 * \file mat.h
 * \class mat
 * \brief mat class using templates
 * 
 * This file contributes a matrix class.
 *
 * This class uses templates, which means the data type of the matrix content
 * may be chosen somewhat freely (at compile-time).
 * Because of the usage of  templates, there is no code for the template itself
 * in the .cpp file for this .h file. In the .cpp file, there is code for 
 * related functions.
 * 
 * As content type, you can use all types/classes, for which the following
 * operations are defined (*with sense*) / properties apply:
 * - assign float/double
 * - assigning 0 must/should create the 0-element
 * - assign the type itself
 * - addition
 * - multiplication
 * - cast to double
 * - no template type
  
 * Some examples:
 * - mat<float,3,3> my3x3Floatmat();
 * - mat<MyComplexNumberClass,2,100> my2x100Complexmat();
 * - mat<MyFancyClassWithAllTheStuffMentionedAbove,3,3> myMatrx(); 
 *
 * Original version by Rodja Trappe
 *
 * <b>Attention!</b> Please note that not all commentaries are up to date
 * because of basic implementation changes.
 */
//------------------------------------------------------------------------------

import vec;
import std.conv;
import hurt.io.stdio;
import hurt.util.slog;
import hurt.string.formatter;

private string genOpBinaryFromTo(int rowLow, int rowHigh, 
		int colLow, int colHigh)() {
	static if(rowLow == rowHigh) {
		return genOpBinaryRow!(rowLow, colLow, colHigh);
	} else {
		return genOpBinaryRow!(rowLow, colLow, colHigh)() ~
			genOpBinaryFromTo!(rowLow+1, rowHigh, colLow, colHigh)();
	}
}

private string genOpBinaryRow(int row, int colLow, int colHigh)() {
	static if(colLow == colHigh) {
		return genOpBinary!(row, colLow);
	} else {
		return genOpBinary!(row, colLow)() ~ 
			genOpBinaryRow!(row, colLow+1, colHigh)();
	}
}

private string genOpBinary(int row, int column)() {
	return "
mat!(T,Rows,"~to!string(column)~") opBinary(string op)(mat!(T," 
	~ to!string(row) ~ "," ~ to!string(column)~") m) if(op == \"*\") {
	mat!(T, Rows,"~to!string(column)~") prod;
	multiplyImpl!(T,Rows,Columns,"~to!string(column)~")(m,prod);
	return prod;}";
}

struct mat(T,size_t Rows, size_t Columns) {
private:

	//! Array with pointers to the row arrays
	//! \todo Is this efficient !??!
	T matrix[Rows*Columns];

public: 
	// Construction/destruction

	//! Standard constructor
	//! Copy contructor
	this(const ref mat!(T, Rows, Columns) mat) {
		this.opAssign(mat);
	}

	//! Contructor with initial value array
	this(const T[] initialValues) {
		size_t initIdx = 0;
		/*foreach(size_t idx, ref T[] it; matrix) {
			foreach(size_t jdx, ref T jd; it) {
				jd = initialValues[initIdx++];
			}
		}*/
		foreach(size_t idx, T it; initialValues) {
			this.matrix[idx] = it;
		}
	}

	this(const T[][] initialValues) {
		assert(initialValues.length == Rows, 
			format("%d != %d", initialValues.length, Rows));
		foreach(idx, it; initialValues) {
			assert(it.length == Columns);
			foreach(jdx, jt; it) {
				matrix[idx*Columns + jdx] = jt;
			}
		}
	}

	//! Contructor with initial value for all elements
	this(const T initialValue) {
		this.opAssign(initialValue);
	}

	//! Constructor with vec3
	/*this(const vec3!T vec) {
		assert(Columns == 1 && Rows == 3);

		// fill with values from original
		for(size_t i = 0; i < 3 ; ++i) {
				matrix[i][0] = vec[i];
		}
	}*/

	//! desctructor
	~this() {}


	//Operators		

	//! Access to the matrix rows / row arrays
	T opIndex(size_t idx, size_t jdx) {
		return matrix[idx*Columns + jdx];
	}

	//! Readonly access to the matrix rows / row arrays
	const(T) opIndex(size_t idx, size_t jdx) const {
		return matrix[idx*Columns + jdx];
	}

	//! Assignment of a matrix
	void opAssign(const ref mat!(T,Rows,Columns) mat) {
		foreach(idx, it; mat.matrix) {
			this.matrix[idx] = it;
		}
	}

	//! Assign v to each matrix (e.g. to initialize)
	void opAssign(const ref T v) {
		foreach(size_t idx, ref T it; matrix) {
			it = v;
		}
	}

	void opIndexAssign(const(T) value, size_t idx, size_t jdx) {
		this.matrix[idx*Columns+jdx] = value;
	}

	//get-methods		

	//! Returns height/number of rows
	size_t getSizeM() const {return Rows;} 

	//! Returns height/number of rows
	size_t getSizeRows() const {return Rows;} 

	//! Returns width/number of columns
	size_t getSizeN() const {return Columns;} 

	//! Returns width/number of columns
	size_t getSizeColumns() const {return Columns;} 


	void print() const {
		foreach(idx, it; matrix) {
			if(idx > 0 && idx % Columns == 0) {
				hurt.io.stdio.println();
			}
			static if(is(T == float)) {
				hurt.io.stdio.printf("%e", it);
			} else {
				hurt.io.stdio.printf("%d", it);
			}
			hurt.io.stdio.print(" ");
		}
		hurt.io.stdio.println();
	}

	//mixin(genOpBinary!(3,3)());
	mixin(genOpBinaryFromTo!(Rows,Rows*2,Columns,Columns*2)());

	/*!
	  \brief multiply two matrixes (operator *)
	  \param mat<T, Columns, Columns2> m
	  \return mat<T, Rows, Columns2>, the multiplyed matrixes
	mat!(T,Rows,Columns) opBinary(string op)(mat!(T,3,3) m) 
			if(op == "*") {
		mat!(T, Rows, Columns) prod;
		multiplyImpl!(T,Rows,Columns,3)(m,prod);
		return prod;
	}

	mat!(T,Rows,Columns) opBinary(string op)(mat!(T,3,4) m) 
			if(op == "*") {
		mat!(T, Rows, Columns) prod;
		multiplyImpl!(T,Rows,Columns,4)(m,prod);
		return prod;
	}*/

	/*!
	  \brief multiply two matrixes (operator *) for performance
	  The user has to assert the size of the result matrix!*/
	private void multiplyImpl(T,size_t Rows, size_t Columns, size_t Columns2)(
			const ref mat!(T,Columns,Columns2) mult, 
			ref mat!(T,Rows,Columns2) prod) {
		for(size_t i = 0; i < Rows; ++i) {
			for(size_t j = 0; j < Columns2; ++j) {
				prod[i,j] = 0;
				for(size_t k = 0; k < Rows; ++k) {
					prod[i,j] = prod[i,j] + (matrix[i*Rows+k] * mult[k,j]);
				}
			}
		}
	}

	/*!
	  \brief Multiply a matrix with a Vector3<Type> (operator *)
	  \param v The Vector to multiply with.
	  \return the product

	  Multiply operator matrix * T
	
	template <class T, unsigned int Rows, unsigned int Columns> 
	mat<T, Rows, 1> mat!(T,Rows,Columns)::operator * (const Vector3<T>& v) const {
	
	mat!(T,Rows,1) opBinary(string op)(const ref vec3!T v) const 
			if(op == "*") {
		assert(Columns==3);
		
		mat!(T,Rows,1) prod;  
		multiplyImpl(v,prod);
		
		return prod;
	}*/
 
/*!
  \brief Multiply a matrix with a Vector3<Type> (operator *)
  \param v The Vector to multiply with.
  \param product result of the operation
template <class T, unsigned int Rows, unsigned int Columns> 
void mat!(T,Rows,Columns)::multiply (const Vector3<T> &v, mat<T, Rows, 1> &product) const {
	*/
	public void multiplyImply(const ref vec3!T v, 
			ref mat!(T,Rows,1) product) const {
		////assert(Columns==3);

		T sum;
		for(size_t i = 0; i < Rows; ++i) {
			sum = 0;
			for(size_t j = 0; j < Columns; ++j) {
				sum = sum + matrix[i*Rows + j] * v[j];
			}
			if(i < 3) {
				product[i,0] = sum;
			} else {
				product[i,0] = matrix[i*Rows+0];
			}
		}
	}

/*!
  \brief multiply with a scalar (matrix * T)
  \param e the scalar
  \return mat!(T,Rows,Columns), the result matrix

  Multiply operator

template<class T, unsigned int Rows, unsigned int Columns> 
mat!(T,Rows,Columns) mat!(T,Rows,Columns)::operator *(const T e) const {*/
	mat!(T,Rows,Columns) opBinary(string op)(T e) {
		//copy of matrix
		static if(op == "*") {
		mat!(T,Rows,Columns) prod = mat!(T,Rows,Columns)(this);
	
		for(size_t i = 0; i < Rows; ++i) {
			for(size_t j = 0; j < Columns; ++j) {
				prod[i][j] *= e;
			}
		}
		return prod; 
		}
	}

/*!
  \brief Multiply T * matrix (operator *)
  \param e the scalar
  \param mat!(T,Rows,Columns) m
  \return mat!(T,Rows,Columns), the multiplyed matrix

  Multiply operator T * matrix

	template<class T, unsigned int Rows, unsigned int Columns> 
	mat!(T,Rows,Columns) operator *(const T &e, const mat!(T,Rows,Columns)& m) {
	mat!(T,Rows,Columns) multiply(const ref T e, //TODO check if needed
			const ref mat!(T,Rows,Columns) m) {
		return m * e;
	}
	*/

/*!
  \brief Subtract two matrixes (operator -)
  \param mat!(T,Rows,Columns) m
  \return mat!(T,Rows,Columns), the subtracted matrixes
  Subtract operator, works per component.
  */

	mat!(T,Rows,Columns) opBinary(string op)(mat!(T, Rows, Columns) m) const 
			if(op == "-") {

		mat!(T, Rows, Columns) sub;
		//T sum;
		for(size_t i = 0; i < Rows; ++i) {
			for(size_t j = 0; j < Columns; ++j) {
				sub[i][j] = matrix[i][j] - m[i][j];
			}
		}
		return sub;
	}

/*!
  \brief Add two matrixes per component (operator +)
  \param mat!(T,Rows,Columns) m
  \return mat!(T,Rows,Columns), the added matrixes

  Addition operator, works per component.*/

	mat!(T,Rows,Columns) opBinary(string op)(mat!(T,Rows,Columns) m) const 
			if(op == "+") {
		mat!(T,Rows,Columns) sum;
		add(m, sum);
		return sum;
	}

/*!
 \brief Addition of matrices for performance

 The user is in charge!
 \todo not yet tested!
 */
	void add(const ref mat!(T,Rows,Columns) addent, 
			ref mat!(T,Rows,Columns) sum) const {
		for(size_t i = 0; i < Rows; ++i) {
			for(size_t j = 0; j < Columns; ++j) {
				sum[i,j] = matrix[i*Rows+j] + addent[i,j];
			}
		}
	}


/**
 * \brief mat equality test
 */
	bool opEquals(const ref mat!(T,Rows,Columns) m) const {
		bool isEqual = true;
		for(size_t i = 0; i < Rows; ++i) {
			for(size_t j = 0; j < Columns; ++j) {
				if (matrix[i*Rows + j] != m[i,j]) {
					return false;
				}
			}
		}
		return true;
	}

/*!
  \brief Transposed matrix
  \return mat!(T,Rows,Columns), the transposed matrix

  This method returns the transposed matrix to the original matrix.
*/
	mat!(T,Columns,Rows) tran() const {
		mat!(T,Columns,Rows) transposed;
		for(size_t i = 0; i < Rows; ++i) {
			for(size_t j = 0; j < Columns; ++j) {
				transposed[j,i] = matrix[i*Rows+j];
			}
		}
		return transposed;
	}

/*!
  \brief Star operator
  \return mat<T, 3, 3>, the star (3,3) of matrix (3,1) 

  This method returns the so called star-matrix.
  Warning: The class T has to be able to provide an element "0".
  This is no problem as it only makes sense to use it with float or double
  or any other similar type. See also the header of this file.
template<class T, unsigned int Rows, unsigned int Columns> 
mat<T, 3, 3> mat!(T,Rows,Columns)::star() const {

	assert (Rows == 3 && Columns == 1);
	mat<T, 3, 3> starmat(0.0);
	for (unsigned int i = 0; i < 3; ++i)
		starmat [i][i] = 0;

	starmat [0][1] = - matrix [2][0];
	starmat [0][2] =   matrix [1][0];
	starmat [1][0] =   matrix [2][0];
	starmat [1][2] = - matrix [0][0];
	starmat [2][0] = - matrix [1][0];
	starmat [2][1] =   matrix [0][0];

	return starmat;
}*/

/*!
  \brief Zero operator
  \return mat!(T,Rows,Columns), the zero matrix of given size

  This method returns the so called zero-matrix.
  Warning: The class T has to be able to provide an element "0".
  This is no problem as it only makes sense to use it with float or double
  or any other similar type. See also the header of this file.
*/
/*!  
  \brief Identity mat createor.  
  \return mat<T, Rows,
  Columns>, the identity matrix of given size

  This method returns the so called zero-matrix. Designed with the 
  "Factory Method Pattern" form Gamma et al.

  <b>Examples:</b>

  To create a 3x3 identity float mat call:
  mat<float, 3, 3> m = mat<float, 3, 3>::createIdentity();


  <b>Warning:</b> The class T has to be able to provide an element "0" and "1".
  This is no problem as it only makes sense to use it with float or double
  or any other similar type. See also the header of this file.
*/
}

static mat!(T,Rows,Columns) zero(T,Rows,Columns)() const {
	mat!(T,Rows,Columns) zeromat = mat!(T,Rows,Columns)(0);
	return zeromat;
}

static mat!(T,Rows,Columns) createIdentity(T,Rows,Columns)() {
	return createDiagonal(1.0);
}

static mat!(T,Rows,Columns) createDiagonal(T,size_t Rows ,size_t Columns)
		(T value) {
	assert(Rows == Columns);
	mat!(T,Rows,Columns) diagonalmat = mat!(T,Rows,Columns)();
	for(size_t i = 0; i < Rows; ++i) {
		diagonalmat[i,i] = value;
	}
	return diagonalmat;
}


/*!  
  \brief Diagonal mat createor.  
  
  \param value The value which should be filled in.
  \return mat!(T,Rows,Columns), a matrix of given size with it's
  diagonal filled with a given T.

  This method returns a diagonal mat with a given T.
  Designed with the "Factory Method Pattern" form Gamma et al.

  <b>Examples:</b>

  To create a 3x3 float mat with 2.2 in diagonal call:
  mat<float, 3, 3> m = mat<float, 3, 3>::createDiagonal(2.2);
template <class T, unsigned int Rows, unsigned int Columns> 


/*!
  \brief Jacobian
  \return jacobian

  This method returns the Jacobian of two vectors. Columnsote that
  it cannot be called from a mat with Columns other than 1, neither
  can it be given an argument mat with Columns other than 1. The
  vectors have to be the "virtual" differences, i.e. real differences
  as we can do nothing but descrete computations.

  Completely outdated and never finished. Should never ever be used!!!
template <class T, unsigned int Rows, unsigned int Columns> 
	template <unsigned int Rows2>
mat<T, Rows, 1> mat!(T,Rows,Columns)::jacobian (const mat<T, Rows2, 1> &deltaArgument)
{
	assert(Columns == 1);
                                                                                 
	mat<T, Rows, Rows2> jacobian;
	for (unsigned int i = 0; i < Rows; ++i) {
		for (unsigned int j = 0; j < Rows2; ++j) {
			if (deltaArgument [j][0] != 0.0) {
				jacobian = matrix [i][0] /
					deltaArgument [j][0];
			}
		}
	}
	return jacobian;

}
 */

/*
 * \brief get matrix part of matrix
 * \param matrix3x3 destiny copied by reference
template <class T, unsigned int Rows, unsigned int Columns> 
void mat!(T,Rows,Columns)::get3x3mat (unsigned int ii, unsigned int jj, mat<T, 3, 3> & matrix3x3) const {

  assert (Rows >= ii+3 && Columns >= jj+3);
  assert (matrix3x3.getSizeRows () == 3 &&
          matrix3x3.getSizeColumns () == 3);

  for (unsigned int i=0; i<3; i++) {
    for (unsigned int j=0; j<3; j++) {
      matrix3x3 [i][j] = matrix [i+ii][j+jj];
    }
  }

}
 */


/**
 * The given matrix needs to be <= the actual one!
 *
 * \param m mat which should be written into the actual
template <class T, unsigned int Rows, unsigned int Columns> 
template <unsigned int Rows2, unsigned int Columns2> 
void mat<T,Rows,Columns>::setValues(const mat<T, Rows2, Columns2> &m) {

	//! \todo muss wieder rein. Gefahr in verzug!
	//assert(Rows2 <= Rows && Columns <= Columns2);

	for (unsigned int i=0; i < Rows2; ++i)
	  for (unsigned int j=0; j < Columns2; ++j)
		matrix[i][j] = m[i][j];
}
 */

/*
 * \brief get matrix part of matrix
 * \param matrixMxColumns destiny copied by reference
template <class T, unsigned int Rows, unsigned int Columns> 
	template <unsigned int M, unsigned int N> 
	void mat!(T,Rows,Columns)::getMxNmat (unsigned int ii, unsigned int jj, mat<T, M, N> &resultmat) const{

  for (unsigned int i=0; i < M; i++) {
    for (unsigned int j=0; j < N; j++) {
      resultmat[i][j] = matrix [i+ii][j+jj];
    }
  }
}
 */

//! tasty typedefs for easy handling of standard matrices
/*
typedef mat<float,1,1> mat1x1;
typedef mat<float,1,3> mat1x3;
typedef mat<float,3,1> mat3x1;
typedef mat<float,3,3> mat3x3;
typedef mat<float,3,6> mat3x6;
typedef mat<float,5,1> mat5x1;
typedef mat<float,5,5> mat5x5;
typedef mat<float,5,6> mat5x6;
typedef mat<float,6,1> mat6x1;
typedef mat<float,6,5> mat6x5;
typedef mat<float,6,6> mat6x6;
typedef mat<float,2,2> mat2x2;
typedef mat<float,2,1> mat2x1;
*/

void main() {
	mat!(int,3,3) m = mat!(int,3,3)([ [1,2,3], [4,5,6], [7,8,9]]);
	mat!(int,3,3) n = mat!(int,3,3)([ [1,2,3], [4,5,6], [7,8,9]]);
	mat!(int,3,4) o = mat!(int,3,4)([ [1,2,3,12], [4,5,6,11], [7,8,9,10]]);
	auto i = mat!(int,3,5)([ [1,2,3,12,13], [4,5,6,11,14], [7,8,9,10,15]]);
	m.print();
	println();
	n.print();
	println();
	o.print();
	println();
	auto z = m * n;
	z.print();
	auto y = m * o;
	println();
	y.print();
	auto w = n * i;
	println();
	w.print();
	//log("%s", genOpBinaryFromTo!(3,3,1,10)());
	auto h = mat!(float,4,4)([[1.0, 2.0, 3.0, 4.0], [5.0, 6.0, 7.0, 8.0],
		[9.0, 10.0, 11.0, 12.0], [13.0, 14.0, 15.0, 16.0]]);

	auto k = createDiagonal!(float,4,4)(1.0);
	auto p = h * h;
	println();
	k.print();
	println();
	h.print();
	println();
	p.print();
	auto oo = h * k;
	println();
	oo.print();
}
