using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using System.Data;
using System.Data.SqlClient;
using AvianTranslator.Models;


namespace AvianTranslator.Controllers   
{
    [Route("api/[controller]")]
    [ApiController]
    public class TranslationsController : ControllerBase
    {
        public readonly IConfiguration _configuration;
        public TranslationsController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpGet]
        public string GetTranslations()
        {
            SqlConnection con = new SqlConnection(_configuration.GetConnectionString("AvianTranslatorCon").ToString());
            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Translation", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            List<Translations> translationList = new List<Translations>();
            Response response = new Response();

            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    Translations translation = new Translations();
                    translation.DanishName = Convert.ToString(dt.Rows[i]["DanishName"]);
                    translation.LatinName = Convert.ToString(dt.Rows[i]["LatinName"]);
                    translation.EnglishName = Convert.ToString(dt.Rows[i]["EnglishName"]);
                    translationList.Add(translation);
                }
            }
            if (translationList.Count > 0)
            {
                return JsonConvert.SerializeObject(translationList);
            }
            else
            {
                response.StatusCode = 100;
                response.ErrorMessage = "No data found";
                return JsonConvert.SerializeObject(response);
            }
        }

        [HttpGet("en/{englishName}")]
        public string getEnglishTranslation(string englishName)
        {
            SqlConnection con = new SqlConnection(_configuration.GetConnectionString("AvianTranslatorCon").ToString());
            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Translation WHERE EnglishName = '" + englishName + "'", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            List<Translations> translationList = new List<Translations>();

            Response response = new Response();

            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    Translations translation = new Translations();
                    translation.DanishName = Convert.ToString(dt.Rows[i]["DanishName"]);
                    translation.LatinName = Convert.ToString(dt.Rows[i]["LatinName"]);
                    translation.EnglishName = Convert.ToString(dt.Rows[i]["EnglishName"]);
                    translationList.Add(translation);
                }
            }
            if (translationList.Count > 0)
            {
                return JsonConvert.SerializeObject(translationList);
            }
            else
            {
                response.StatusCode = 100;
                response.ErrorMessage = "No data found";
                return JsonConvert.SerializeObject(response);
            }
        }

        [HttpGet("da/{danishName}")]
        public string getDanishTranslation(string danishName)
        {
            SqlConnection con = new SqlConnection(_configuration.GetConnectionString("AvianTranslatorCon").ToString());
            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Translation WHERE DanishName = '" + danishName + "'", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            List<Translations> translationList = new List<Translations>();

            Response response = new Response();

            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    Translations translation = new Translations();
                    translation.DanishName = Convert.ToString(dt.Rows[i]["DanishName"]);
                    translation.LatinName = Convert.ToString(dt.Rows[i]["LatinName"]);
                    translation.EnglishName = Convert.ToString(dt.Rows[i]["EnglishName"]);
                    translationList.Add(translation);
                }
            }
            if (translationList.Count > 0)
            {
                return JsonConvert.SerializeObject(translationList);
            }
            else
            {
                response.StatusCode = 100;
                response.ErrorMessage = "No data found";
                return JsonConvert.SerializeObject(response);
            }
        }

        [HttpGet("la/{latinName}")]
        public string getLatinTranslation(string latinName)
        {
            SqlConnection con = new SqlConnection(_configuration.GetConnectionString("AvianTranslatorCon").ToString());
            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Translation WHERE LatinName = '" + latinName + "'", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            List<Translations> translationList = new List<Translations>();

            Response response = new Response();

            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    Translations translation = new Translations();
                    translation.DanishName = Convert.ToString(dt.Rows[i]["DanishName"]);
                    translation.LatinName = Convert.ToString(dt.Rows[i]["LatinName"]);
                    translation.EnglishName = Convert.ToString(dt.Rows[i]["EnglishName"]);
                    translationList.Add(translation);
                }
            }
            if (translationList.Count > 0)
            {
                return JsonConvert.SerializeObject(translationList);
            }
            else
            {
                response.StatusCode = 100;
                response.ErrorMessage = "No data found";
                return JsonConvert.SerializeObject(response);
            }
        }

        [HttpGet("search/{searchName}")]
        public string searchTranslation(string searchName)
        {
            SqlConnection con = new SqlConnection(_configuration.GetConnectionString("AvianTranslatorCon").ToString());
            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Translation WHERE LatinName LIKE '%" + searchName + "%' OR EnglishName  LIKE '%" + searchName + "%'  OR DanishName  LIKE '%" + searchName + "&'", con);
            DataTable dt = new DataTable();
            da.Fill(dt);
            List<Translations> translationList = new List<Translations>();

            Response response = new Response();

            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    Translations translation = new Translations();
                    translation.DanishName = Convert.ToString(dt.Rows[i]["DanishName"]);
                    translation.LatinName = Convert.ToString(dt.Rows[i]["LatinName"]);
                    translation.EnglishName = Convert.ToString(dt.Rows[i]["EnglishName"]);
                    translationList.Add(translation);
                }
            }
            if (translationList.Count > 0)
            {
                return JsonConvert.SerializeObject(translationList);
            }
            else
            {
                response.StatusCode = 100;
                response.ErrorMessage = "No data found";
                return JsonConvert.SerializeObject(response);
            }
        }
    }
}
