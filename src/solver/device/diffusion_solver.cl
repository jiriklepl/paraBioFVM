typedef int index_t;

#ifdef DOUBLE
typedef double real_t;
typedef atomic_double atomic_real_t;
#else
typedef float real_t;
typedef atomic_float atomic_real_t;
#endif

kernel void solve_slice_2d_x(global real_t* restrict densities, global const real_t* b, constant real_t* c,
							 index_t substrates_count, index_t x_size, index_t y_size)
{
	int id = get_global_id(0);
	index_t y = id / substrates_count;
	index_t s = id % substrates_count;

	const real_t a = c[s];

	real_t tmp = densities[(y * x_size) * substrates_count + s];

	for (index_t x = 1; x < x_size; x++)
	{
		tmp = densities[(y * x_size + x) * substrates_count + s] - a * b[(x - 1) * substrates_count + s] * tmp;
		densities[(y * x_size + x) * substrates_count + s] = tmp;
	}

	tmp *= b[(x_size - 1) * substrates_count + s];
	densities[(y * x_size + x_size - 1) * substrates_count + s] = tmp;


	for (index_t x = x_size - 2; x >= 0; x--)
	{
		tmp = (densities[(y * x_size + x) * substrates_count + s] - a * tmp) * b[x * substrates_count + s];
		densities[(y * x_size + x) * substrates_count + s] = tmp;
	}
}

kernel void solve_slice_3d_x(global real_t* restrict densities, global const real_t* restrict b,
							 constant real_t* restrict c, index_t substrates_count, index_t x_size, index_t y_size,
							 index_t z_size)
{
	int id = get_global_id(0);
	index_t z = id / (y_size * substrates_count);
	index_t y = (id / substrates_count) % y_size;
	index_t s = id % substrates_count;

	const real_t a = c[s];

	real_t tmp = densities[(z * x_size * y_size + y * x_size) * substrates_count + s];

	// for (index_t z = 0; z < z_size; z++)
	{
		// for (index_t y = 0; y < y_size; y++)
		{
			for (index_t x = 1; x < x_size; x++) // serial
			{
				// for (index_t s = 0; s < substrates_count; s++)
				{
					tmp = densities[(z * x_size * y_size + y * x_size + x) * substrates_count + s]
						  - a * b[(x - 1) * substrates_count + s] * tmp;
					densities[(z * x_size * y_size + y * x_size + x) * substrates_count + s] = tmp;
				}
			}

			// for (index_t s = 0; s < substrates_count; s++)
			{
				tmp *= b[(x_size - 1) * substrates_count + s];
				densities[(z * x_size * y_size + y * x_size + x_size - 1) * substrates_count + s] = tmp;
			}

			for (index_t x = x_size - 2; x >= 0; x--) // serial
			{
				// for (index_t s = 0; s < substrates_count; s++)
				{
					tmp = (densities[(z * x_size * y_size + y * x_size + x) * substrates_count + s] - a * tmp)
						  * b[x * substrates_count + s];
					densities[(z * x_size * y_size + y * x_size + x) * substrates_count + s] = tmp;
				}
			}
		}
	}
}

kernel void solve_slice_2d_y(global real_t* restrict densities, global const real_t* b, constant real_t* c,
							 index_t substrates_count, index_t x_size, index_t y_size)
{
	int id = get_global_id(0);
	index_t x = id / substrates_count;
	index_t s = id % substrates_count;

	const real_t a = c[s];

	real_t tmp = densities[x * substrates_count + s];

	for (index_t y = 1; y < y_size; y++)
	{
		tmp = densities[(y * x_size + x) * substrates_count + s] - a * b[(y - 1) * substrates_count + s] * tmp;
		densities[(y * x_size + x) * substrates_count + s] = tmp;
	}

	tmp *= b[(y_size - 1) * substrates_count + s];
	densities[((y_size - 1) * x_size + x) * substrates_count + s] = tmp;

	for (index_t y = y_size - 2; y >= 0; y--)
	{
		tmp = (densities[(y * x_size + x) * substrates_count + s] - a * tmp) * b[y * substrates_count + s];
		densities[(y * x_size + x) * substrates_count + s] = tmp;
	}
}

kernel void solve_slice_3d_y(global real_t* restrict densities, global const real_t* restrict b,
							 constant real_t* restrict c, index_t substrates_count, index_t x_size, index_t y_size,
							 index_t z_size)
{
	int id = get_global_id(0);
	index_t z = id / (x_size * substrates_count);
	index_t x = (id / substrates_count) % x_size;
	index_t s = id % substrates_count;

	const real_t a = c[s];

	real_t tmp = densities[(z * x_size * y_size + x) * substrates_count + s];

	// for (index_t z = 0; z < z_size; z++)
	{
		for (index_t y = 1; y < y_size; y++) // serial
		{
			// for (index_t x = 0; x < x_size; x++)
			{
				// for (index_t s = 0; s < substrates_count; s++)
				{
					tmp = densities[(z * x_size * y_size + y * x_size + x) * substrates_count + s]
						  - a * b[(y - 1) * substrates_count + s] * tmp;
					densities[(z * x_size * y_size + y * x_size + x) * substrates_count + s] = tmp;
				}
			}
		}

		// for (index_t x = 0; x < x_size; x++)
		{
			// for (index_t s = 0; s < substrates_count; s++)
			{
				tmp *= b[(y_size - 1) * substrates_count + s];
				densities[(z * x_size * y_size + (y_size - 1) * x_size + x) * substrates_count + s] = tmp;
			}
		}

		for (index_t y = y_size - 2; y >= 0; y--) // serial
		{
			// for (index_t x = 0; x < x_size; x++)
			{
				// for (index_t s = 0; s < substrates_count; s++)
				{
					tmp = (densities[(z * x_size * y_size + y * x_size + x) * substrates_count + s] - a * tmp)
						  * b[y * substrates_count + s];
					densities[(z * x_size * y_size + y * x_size + x) * substrates_count + s] = tmp;
				}
			}
		}
	}
}

kernel void solve_slice_3d_z(global real_t* restrict densities, global const real_t* restrict b,
							 constant real_t* restrict c, index_t substrates_count, index_t x_size, index_t y_size,
							 index_t z_size)
{
	int id = get_global_id(0);
	index_t y = id / (x_size * substrates_count);
	index_t x = (id / substrates_count) % x_size;
	index_t s = id % substrates_count;

	const real_t a = c[s];

	real_t tmp = densities[(y * x_size + x) * substrates_count + s];

	for (index_t z = 1; z < z_size; z++) // serial
	{
		// for (index_t y = 0; y < y_size; y++)
		{
			// for (index_t x = 0; x < x_size; x++)
			{
				// for (index_t s = 0; s < substrates_count; s++)
				{
					tmp = densities[(z * x_size * y_size + y * x_size + x) * substrates_count + s]
						  - a * b[(z - 1) * substrates_count + s] * tmp;
					densities[(z * x_size * y_size + y * x_size + x) * substrates_count + s] = tmp;
				}
			}
		}
	}

	// for (index_t y = 0; y < y_size; y++)
	{
		// for (index_t x = 0; x < x_size; x++)
		{
			// for (index_t s = 0; s < substrates_count; s++)
			{
				tmp *= b[(z_size - 1) * substrates_count + s];
				densities[((z_size - 1) * x_size * y_size + y * x_size + x) * substrates_count + s] = tmp;
			}
		}
	}

	for (index_t z = z_size - 2; z >= 0; z--) // serial
	{
		// for (index_t y = 0; y < y_size; y++)
		{
			// for (index_t x = 0; x < x_size; x++)
			{
				// for (index_t s = 0; s < substrates_count; s++)
				{
					tmp = (densities[(z * x_size * y_size + y * x_size + x) * substrates_count + s] - a * tmp)
						  * b[z * substrates_count + s];
					densities[(z * x_size * y_size + y * x_size + x) * substrates_count + s] = tmp;
				}
			}
		}
	}
}
