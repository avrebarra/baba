const key = "babba.language";

const useLanguageSwitcher = async () => {
  let val = localStorage.getItem(key) || "en-pt";
  const set = (v) => {
    val = v;
    localStorage.setItem(key, v);
  };

  const get = () => val;

  return { get, set };
};
