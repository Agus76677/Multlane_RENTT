import os
from mult_bank_NTT_model import compare_results, P


def main():
    base = os.path.join(os.path.dirname(__file__), "testbench_data")

    compare_results(os.path.join(base, "bankf"),   os.path.join(base, "ploy_f_hat.txt"), P)
    compare_results(os.path.join(base, "bankg"),   os.path.join(base, "ploy_g_hat.txt"), P)
    compare_results(os.path.join(base, "bankhat"), os.path.join(base, "ploy_h_hat.txt"), P)
    compare_results(os.path.join(base, "bankh"),   os.path.join(base, "ploy_h.txt"), P)


if __name__ == "__main__":
    main()
